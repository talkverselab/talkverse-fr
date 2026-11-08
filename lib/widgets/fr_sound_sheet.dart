import 'dart:async';

import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/platform.dart';
import '../core/theme.dart';
import '../services/fr_phonetics.dart';
import '../services/tts_service.dart';

/// 글자 탭 → 발음 상세 시트(일본어앱 kana_sound_sheet 와 같은 틀).
/// 열리면 1초 뒤 자동 재생, IPA·소리 내는 법·조음 위치 그림·모음 위치(프랑스어 vs 한국어)·한국어 화자 비교·다시 듣기.
Future<void> showFrSoundSheet(BuildContext context, FrSound s, Color color) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.washi,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _Sheet(s: s, color: color),
    );

class _Sheet extends StatefulWidget {
  final FrSound s;
  final Color color;
  const _Sheet({required this.s, required this.color});
  @override
  State<_Sheet> createState() => _SheetState();
}

class _SheetState extends State<_Sheet> {
  Timer? _auto;
  bool _showPic = false;

  @override
  void initState() {
    super.initState();
    _auto = Timer(const Duration(seconds: 1), () => TtsService.instance.speak(widget.s.say));
  }

  @override
  void dispose() {
    _auto?.cancel();
    TtsService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s, c = widget.color;
    final firstExample = s.example.split(' · ').first;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (context, scroll) => SafeArea(
        top: false,
        child: ListView(
          controller: scroll,
          padding: EdgeInsets.fromLTRB(20, 12, 20, 32 + bottomInset(context)),
          children: [
            Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.sumiLight.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Row(children: [
              Container(
                constraints: const BoxConstraints(minWidth: 84, minHeight: 84),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(10)),
                child: Text(s.key, textAlign: TextAlign.center,
                    style: TextStyle(fontSize: s.key.length > 3 ? 20 : 40, fontWeight: FontWeight.w800, color: AppColors.washi)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.rd, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: c)),
                  const SizedBox(height: 4),
                  Text('IPA [${s.ipa}]', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.sumi)),
                ]),
              ),
              IconButton(iconSize: 44, color: c, tooltip: tr('다시 듣기'), icon: const Icon(Icons.play_circle_fill),
                  onPressed: () => TtsService.instance.speak(s.say)),
            ]),
            const SizedBox(height: 16),
            _box(c, tr('🔤 예'), child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.example, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.sumi)),
                  Text(s.exampleRd, style: TextStyle(fontSize: 13, color: c)),
                  Text(s.exampleKo, style: const TextStyle(fontSize: 13, color: AppColors.sumiLight)),
                ]),
              ),
              IconButton(color: c, tooltip: tr('예 듣기'), icon: const Icon(Icons.volume_up), onPressed: () => TtsService.instance.speak(firstExample)),
            ])),
            const SizedBox(height: 14),
            _box(c, tr('👄 소리 내는 법 · 입모양'), text: s.how),
            if (s.vowel != null) ...[
              const SizedBox(height: 14),
              _box(c, tr('📍 모음 위치 — 프랑스어 vs 한국어'), child: _VowelChart(s: s, color: c)),
            ],
            if (s.places.isNotEmpty) ...[
              const SizedBox(height: 6),
              InkWell(
                onTap: () => setState(() => _showPic = !_showPic),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    Icon(_showPic ? Icons.expand_less : Icons.expand_more, size: 18, color: c),
                    Flexible(
                      child: Text(trf('조음 위치 그림 보기 — {0}', [s.places.map((p) => '$p ${tr(kPlaceNames[p] ?? '')}').join(' · ')]),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c)),
                    ),
                  ]),
                ),
              ),
              if (_showPic) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(color: Colors.white, padding: const EdgeInsets.all(8),
                      child: Image.asset('assets/images/ipa/places_of_articulation.png', fit: BoxFit.contain, height: 320)),
                ), // 임시 그림 — 출시 전 Grok 그림으로 교체(사용자 지시 2026-11-08, 출처 표기 없음)
              ],
            ],
            const SizedBox(height: 14),
            _box(c, tr('🇰🇷 한국어와 비교'), text: trf('비슷한 소리: {0}\n\n{1}', [s.korSim, s.korDiff])),
          ],
        ),
      ),
    );
  }

  Widget _box(Color c, String title, {String? text, Widget? child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.calDeep, borderRadius: BorderRadius.circular(10), border: Border.all(color: c.withValues(alpha: 0.35))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: c)),
          const SizedBox(height: 8),
          child ?? Text(text ?? '', style: const TextStyle(fontSize: 13.5, height: 1.55, color: AppColors.sumi)),
        ]),
      );
}

/// 모음 사다리꼴 위에 이 소리(강조색 ●)와 한국어 모음(회색 ●)을 함께 찍는다.
class _VowelChart extends StatelessWidget {
  final FrSound s;
  final Color color;
  const _VowelChart({required this.s, required this.color});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AspectRatio(aspectRatio: 1.45, child: CustomPaint(painter: _Trap(s, color), size: Size.infinite)),
        const SizedBox(height: 6),
        Text(tr('왼쪽 = 혀 앞 · 오른쪽 = 혀 뒤 · 위 = 입 좁게 · 아래 = 입 크게') + (s.rounded ? tr(' · 입술 둥글게') : ''),
            style: const TextStyle(fontSize: 11, color: AppColors.sumiLight)),
      ]);
}

class _Trap extends CustomPainter {
  final FrSound s;
  final Color color;
  _Trap(this.s, this.color);

  Offset _pt(Size z, (double, double) v) {
    const l = 24.0, t = 12.0, b = 16.0, r = 12.0;
    final h = z.height - t - b, w = z.width - l - r;
    final left = l + (v.$2 * w * 0.35); // 아래로 갈수록 왼쪽 변이 안쪽(사다리꼴)
    return Offset(left + v.$1 * (l + w - left), t + v.$2 * h);
  }

  @override
  void paint(Canvas canvas, Size z) {
    final line = Paint()
      ..color = AppColors.gualdaDeep.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final path = Path()
      ..moveTo(_pt(z, (0, 0)).dx, _pt(z, (0, 0)).dy)
      ..lineTo(_pt(z, (1, 0)).dx, _pt(z, (1, 0)).dy)
      ..lineTo(_pt(z, (1, 1)).dx, _pt(z, (1, 1)).dy)
      ..lineTo(_pt(z, (0, 1)).dx, _pt(z, (0, 1)).dy)
      ..close();
    canvas.drawPath(path, line);
    void dot((double, double) v, Color c, String label, double r, {bool bold = false}) {
      final p = _pt(z, v);
      canvas.drawCircle(p, r, Paint()..color = c);
      final tp = TextPainter(
          text: TextSpan(text: label, style: TextStyle(fontSize: bold ? 14 : 12, color: c, fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
          textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(canvas, p + Offset(r + 3, -tp.height / 2));
    }

    kKoVowels.forEach((k, v) => dot(v, AppColors.gualdaDeep, k, 4));
    dot(s.vowel!, color, '[${s.ipa}]', 7, bold: true);
  }

  @override
  bool shouldRepaint(covariant _Trap old) => old.s != s;
}
