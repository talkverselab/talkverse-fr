#!/usr/bin/env python3
"""회화 장면 컷(만화 1컷 = 턴 2개, 글자·말풍선 없음)을 Grok(PC 크롬 9250, 「빠른」)에 받아 ~/talkverse/fr-art/scene/fr/<편id>/cut<N>.jpg(1168×784)로 둔다.
ja tools/grok_scene_batch.py 를 줄여 옮김(2026-11-22). 한 방에서 이어서, 요청마다 그림 4장 이하, 답은 3분까지만(넘으면 중지).
  GROK_CDP_PORT=9250 python3 tools/grok_scene.py [--room <방 주소>] [--max 10] <편id>...   올리기는 tools/scene_upload.py"""
import base64, glob, json, os, subprocess, sys, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import grok_cdp as G
from grok_text import new_tab, close_tab
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ART = os.path.expanduser('~/talkverse/fr-art/scene/fr')
SHEET = os.path.join(ROOT, 'data/review/art/chars_fr_v1.jpg')
PC_ATT = 'D:\\grok_att\\fr\\chars_fr_v1.jpg'
CAST = {'Camille': '시트의 Camille(밤색 웨이브 단발·일자 앞머리, 줄무늬 티 + 카멜 트렌치)',
        'Léa': '시트의 Léa(적갈색 곱슬머리 느슨한 올림머리, 머스터드 니트·데님 롱스커트)',
        'Hugo': '시트의 Hugo(짙은 곱슬머리·짧은 수염, 데님 재킷)',
        'Théo': '시트의 Théo(가장 큰 키, 밝은 갈색 사이드 헤어, 네이비 피코트)',
        '{name}': '시트의 남자 학습자(프렌치 블루 후드티 + 베이지 팬츠·갈색 백팩)'}
a = sys.argv[1:]
room = a[a.index('--room') + 1] if '--room' in a else ''
mx = int(a[a.index('--max') + 1]) if '--max' in a else 10
ids = [x for i, x in enumerate(a) if not x.startswith('--') and (i == 0 or a[i - 1] not in ('--room', '--max'))]
IMGS = "[...document.querySelectorAll('img')].filter(i=>i.src.includes('assets.grok.com')&&i.naturalWidth>=300).map(i=>i.src)"

def who(n): return CAST.get(n, f'{n}(시트에 없는 조연 — 이름·역할에 맞는 차림의 프랑스 사람, 같은 그림 톤, 실존 인물 닮지 않게)')

def prompt(ep, chunk):
    lines = [f'컷{n}: ' + ' / '.join(f"{t['speaker']}「{t['fr']}」({t['ko']})" for t in pair) for n, pair in chunk]
    cast = ', '.join(f'{k} = {who(v)}' for k, v in ep['speakers'].items())
    return (f"[SC-{ep['id']}] 이미지 {len(chunk)}장을 생성해 주세요(글 설명 없이 그림만, 컷마다 한 장씩 따로). 프랑스어 학습 앱 회화의 장면 컷입니다. "
            f"첨부 = 우리 앱 인물 기준 그림(이 인물들의 얼굴·머리·옷을 그대로). 그림 톤도 첨부와 같게, 프랑스의 실제 장소 느낌, 3:2 가로. "
            f"그림 안에 글자·말풍선·간판 글씨·로고 없음. 실존 인물·브랜드 금지. 장면: {ep['scene']} 등장: {cast} "
            f"각 컷은 아래 두 대사가 오가는 순간의 표정·동작·장소를 한 장으로(대사는 그리지 말고 상황만): " + ' '.join(lines))

def fit(src, dst):
    o = subprocess.run(['sips', '-g', 'pixelWidth', '-g', 'pixelHeight', src], capture_output=True, text=True).stdout.split()
    w, h = int(o[o.index('pixelWidth:') + 1]), int(o[o.index('pixelHeight:') + 1])
    cw, ch = (int(h * 1.5), h) if w / h > 1.5 else (w, int(w / 1.5))
    subprocess.run(['sips', '-s', 'format', 'jpeg', '-s', 'formatOptions', '88', '--cropToHeightWidth', str(ch), str(cw), src, '--out', dst], capture_output=True)
    subprocess.run(['sips', '-z', '784', '1168', dst], capture_output=True)

subprocess.run(['ssh', 'pc', 'cmd /c if not exist D:\\grok_att\\fr mkdir D:\\grok_att\\fr'], capture_output=True)
subprocess.run(['scp', '-q', SHEET, 'pc:D:/grok_att/fr/'], check=True)
made = 0
for eid in ids:
    ep = json.load(open(glob.glob(os.path.join(ROOT, f'assets/data/dialogues/R*/*/{eid}.json'))[0], encoding='utf-8'))
    out = os.path.join(ART, eid); os.makedirs(out, exist_ok=True)
    ts = ep['turns']
    cuts = [((i // 2) + 1, ts[i:i + 2]) for i in range(0, len(ts), 2)]
    miss = [c for c in cuts if not os.path.exists(os.path.join(out, f'cut{c[0]}.jpg'))]
    for k in range(0, len(miss), 4):
        if made >= mx: break
        chunk = miss[k:k + min(4, mx - made)]
        t = new_tab(room or 'https://grok.com/')
        try:
            c = G.CDP(t); c.call('Page.bringToFront')
            for _ in range(40):
                if c.ev("!!(%s)" % G.FIND): break
                time.sleep(1)
            time.sleep(4)
            model = c.ev("[...document.querySelectorAll('button')].map(b=>b.getAttribute('aria-label')||'').find(x=>/^모델/.test(x))||''")
            if '빠른' not in model: sys.exit('Grok 모델이 빠른 모드가 아님: ' + model)
            doc = c.call('DOM.getDocument', depth=-1, pierce=True)
            node = c.call('DOM.querySelector', nodeId=doc['root']['nodeId'], selector='input[type=file]')
            c.call('DOM.setFileInputFiles', nodeId=node['nodeId'], files=[PC_ATT]); time.sleep(6)
            before = set(c.ev(IMGS) or [])
            c.ev("(()=>{const e=%s;e.focus();return 1})()" % G.FIND)
            c.call('Input.insertText', text=prompt(ep, chunk)); time.sleep(1)
            for typ in ('keyDown', 'keyUp'):
                c.call('Input.dispatchKeyEvent', type=typ, key='Enter', code='Enter', windowsVirtualKeyCode=13, nativeVirtualKeyCode=13)
            t0, new, same = time.time(), [], 0
            while time.time() - t0 < 180:  # 사용자 지시: 3분까지만
                time.sleep(10)
                if (c.ev("(document.body.innerText.match(/한도에 도달|limit reached/g)||[]).length") or 0): print('LIMIT'); sys.exit(3)
                cur = [s for s in dict.fromkeys(c.ev(IMGS) or []) if s not in before]
                loading = c.ev("[...document.querySelectorAll('img')].some(i=>i.src.startsWith('data:image')&&i.naturalWidth>200)")
                same = same + 1 if (cur == new and len(cur) >= len(chunk) and not loading) else 0
                new = cur
                if same >= 2: break
            else:
                c.ev("(()=>{const b=[...document.querySelectorAll('button')].find(e=>/중지|stop/i.test((e.getAttribute('aria-label')||'')+' '+e.innerText));if(b)b.click();return 1})()")
                print('STOPPED', eid)
            room = room or (c.ev('location.href') or '').split('?')[0]
            print(eid, 'imgs', len(new), 'room', room, flush=True)
            for (n, _), url in zip(chunk, new[:len(chunk)]):
                d = c.ev("fetch(%s,{credentials:'include'}).then(r=>r.blob()).then(b=>new Promise(ok=>{const f=new FileReader();f.onload=()=>ok(f.result);f.readAsDataURL(b)}))" % json.dumps(url))
                if not (isinstance(d, str) and d.startswith('data:')): print('FAIL 받기', eid, n); continue
                raw = os.path.join(out, f'.raw{n}'); open(raw, 'wb').write(base64.b64decode(d.split(',', 1)[1]))
                fit(raw, os.path.join(out, f'cut{n}.jpg')); os.remove(raw); made += 1
                print('OK', eid, f'cut{n}', flush=True)
        finally:
            close_tab(t)
        time.sleep(15)
print('DONE 컷', made, 'room', room)
