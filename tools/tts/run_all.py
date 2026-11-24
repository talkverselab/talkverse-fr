#!/usr/bin/env python3
"""전편 회화 음성 생성 진행기(M6 에서 길게 돈다). 묶음마다: 작업 파일 → PC 생성 → 받아 오기 → 받아쓰기 검사·재생성(두 번까지) → mp4·R2·D1.
  <venv>/bin/python tools/tts/run_all.py <작업폴더> [묶음 크기=12]     끝난 편은 <작업폴더>/done.txt 에 적히고 다시 돌리면 건너뛴다.
PC 쪽은 작업 스케줄러 'TTS job 2060'(run_job.sh)이 돈다 — 참고 음성 2060, 문장 3090. 중간에 멈춰도 있는 파일은 건너뛰고 이어서 한다."""
import glob, json, os, subprocess, sys, time
import ttslib as L
PC = 'Administrator@100.127.143.37'; HERE = os.path.dirname(os.path.abspath(__file__))
work = sys.argv[1]; N = int(sys.argv[2]) if len(sys.argv) > 2 else 12
os.makedirs(f'{work}/job', exist_ok=True); os.makedirs(f'{work}/wav', exist_ok=True)
log = lambda *a: print(time.strftime('%H:%M:%S'), *a, flush=True)


def sh(*a, check=True, **k):
    return subprocess.run(a, check=check, capture_output=True, text=True, **k)


def pc_run():
    """작업 스케줄러를 돌리고 JOB_END 까지 기다린다."""
    while 'Ready' not in sh('ssh', PC, "(Get-ScheduledTask -TaskName 'TTS job 2060').State", check=False).stdout:
        time.sleep(30)                     # 앞선 작업(참고 음성 등)이 끝날 때까지
    sh('scp', '-q', f'{work}/job/moss_jobs.json', f'{PC}:D:/tts_test/job/')
    sh('ssh', PC, "Remove-Item D:\\tts_test\\job\\vox_jobs.json -ErrorAction SilentlyContinue; Start-ScheduledTask -TaskName 'TTS job 2060'")
    time.sleep(20)
    while True:
        r = sh('ssh', PC, "(Get-ScheduledTask -TaskName 'TTS job 2060').State", check=False).stdout
        if 'Ready' in r:
            return
        time.sleep(30)


def fetch(path):
    """PC → M6. scp 가 조용히 실패해 폴더째 빠지는 일이 있어(11-24 r2_culture_d1) 세 번까지 다시 받고, 그래도 안 되면 기록한다.
    재생성본(retake/…)은 없을 수도 있어 한 번만 받는다."""
    os.makedirs(os.path.dirname(f'{work}/wav/{path}') , exist_ok=True)
    for i in range(1 if path.startswith('retake/') else 3):
        r = sh('scp', '-q', '-r', f'{PC}:D:/tts_test/job/out/fr/{path}', os.path.dirname(f'{work}/wav/{path}') + '/', check=False)
        if r.returncode == 0:
            return
        time.sleep(10)
    if not path.startswith('retake/'):
        log('받기 실패', path, r.stderr.strip()[-120:])


done = set(open(f'{work}/done.txt').read().split()) if os.path.exists(f'{work}/done.txt') else set()
rel = {os.path.basename(p)[:-5] for p in glob.glob(f'{L.R}/assets/data/dialogues/R*/*/*.json')}   # 앱에 든 편 전부(fr 65편)
ids = [e for e in L.planned() if e in rel and e not in done]
log('남은 편', len(ids))
if ids:   # 참고 음성(2060) 먼저 — 없으면 문장 생성이 첫 조각에서 멈춘다(11-24 65편 전부 실패). 이미 있는 파일은 PC 가 건너뜀
    for n in ('vox_jobs.json', 'moss_jobs.json'):
        if os.path.exists(f'{work}/job/{n}'):
            os.remove(f'{work}/job/{n}')
    log(sh(sys.executable, f'{HERE}/make_jobs.py', f'{work}/job', '--refs', *ids).stdout.strip())
    need = {os.path.basename(x['out']) for x in json.load(open(f'{work}/job/vox_jobs.json', encoding='utf-8'))}
    have = set(sh('ssh', PC, "(Get-ChildItem D:\\tts_test\\job\\out\\ref_fr -Filter *.wav | ?{$_.Length -gt 1000}).Name", check=False).stdout.split())
    if need <= have:   # 다 있으면 건너뜀 — 있는 파일을 건너뛰기만 해도 PC 가 모델을 읽느라 15분 걸렸다(11-24)
        os.remove(f'{work}/job/vox_jobs.json'); log('참고 음성 이미 있음', len(need), '— 건너뜀')
    else:
        log('참고 음성 없는 것', len(need - have))
        while 'Ready' not in sh('ssh', PC, "(Get-ScheduledTask -TaskName 'TTS job 2060').State", check=False).stdout:
            time.sleep(30)
        sh('scp', '-q', f'{work}/job/vox_jobs.json', f'{PC}:D:/tts_test/job/')
        sh('ssh', PC, "Remove-Item D:\\tts_test\\job\\moss_jobs.json -ErrorAction SilentlyContinue; Start-ScheduledTask -TaskName 'TTS job 2060'")
        time.sleep(20)
        while 'Ready' not in sh('ssh', PC, "(Get-ScheduledTask -TaskName 'TTS job 2060').State", check=False).stdout:
            time.sleep(30)
        os.remove(f'{work}/job/vox_jobs.json'); log('참고 음성 끝')
for i in range(0, len(ids), N):
    eps = ids[i:i + N]
    sh(sys.executable, f'{HERE}/make_jobs.py', f'{work}/job', *eps); pc_run()
    for ep in eps:
        fetch(ep)
    for rnd in range(3):
        # whisper 가 한 파일에서 멈추는 일이 있어(일본어 7시간) 편별 하위 프로세스 + 600초 제한. 넘기면 그 편 재생성본은 버리고 넘어간다.
        tot = 0
        for ep in eps:
            try:
                r = subprocess.run([sys.executable, f'{HERE}/qa.py', f'{work}/wav', ep, '--jobs', f'{work}/job/qa_{ep}.json'], capture_output=True, text=True, timeout=600)
                log(r.stdout.strip() or r.stderr.strip()[-200:])
            except subprocess.TimeoutExpired:
                log('TIMEOUT', ep)
                for f in glob.glob(f'{work}/wav/retake/{ep}/*.wav'):
                    os.remove(f)
        jobs = []
        for ep in eps:
            p = f'{work}/job/qa_{ep}.json'
            if os.path.exists(p):
                jobs += json.load(open(p)); os.remove(p)
        tot = len(jobs)
        if tot == 0:
            break
        json.dump(jobs, open(f'{work}/job/moss_jobs.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=0)
        pc_run()
        for ep in eps:
            fetch(f'retake/{ep}')
    for ep in eps:   # 마지막(3회째) 재생성본 반영 — 빠지면 받아만 두고 예전 판을 올린다(11-24)
        try:
            subprocess.run([sys.executable, f'{HERE}/qa.py', f'{work}/wav', ep], capture_output=True, text=True, timeout=600)
        except subprocess.TimeoutExpired:
            log('TIMEOUT', ep)
    for ep in eps:
        r = sh(sys.executable, f'{HERE}/pack.py', f'{work}/wav', ep, '--upload', check=False)
        if r.returncode:
            log('실패', ep, (r.stderr or r.stdout)[-300:]); continue
        log(r.stdout.strip()); open(f'{work}/done.txt', 'a').write(ep + '\n')
log('끝')
