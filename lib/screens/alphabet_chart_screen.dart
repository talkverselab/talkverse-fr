import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/platform.dart';
import '../core/theme.dart';
import '../services/fr_phonetics.dart';
import '../services/tts_service.dart';
import '../widgets/fr_sound_sheet.dart';

/// 알파벳과 발음 — 일본어앱 「50음도와 발음」과 같은 틀(사용자 지시 2026-11-08, 공통 프롬프터 §5-3).
/// 묶음 칩(알파벳·모음·비모음·자음·연음) + 격자 + 보조 표기 토글(한글 독음 → IPA → 끔). 칸 탭 = 발음 상세 시트.
class AlphabetChartScreen extends StatefulWidget {
  const AlphabetChartScreen({super.key});
  @override
  State<AlphabetChartScreen> createState() => _AlphabetChartScreenState();
}

class _AlphabetChartScreenState extends State<AlphabetChartScreen> {
  int _set = 0;
  int _aux = 0; // 0 한글 독음 · 1 IPA · 2 끔
  static const _colors = [AppColors.beni, AppColors.rojoDeep, AppColors.oliva, AppColors.mar, AppColors.irregular];

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = soundsOf(_set);
    final color = _colors[_set];
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(tr('알파벳과 발음'), style: const TextStyle(color: AppColors.sumi, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(tr('탭하면 발음·IPA 상세'), style: const TextStyle(color: AppColors.sumiLight, fontSize: 10, letterSpacing: 1)),
        ]),
        actions: [
          TextButton(
            onPressed: () => setState(() => _aux = (_aux + 1) % 3),
            child: Text([tr('독음'), 'IPA', tr('끔')][_aux], style: TextStyle(fontWeight: FontWeight.w800, color: _aux == 2 ? AppColors.sumiLight : AppColors.beni)),
          ),
        ],
      ),
      body: Column(children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(children: List.generate(kSets.length, (i) {
            final sel = _set == i;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(tr(kSets[i])),
                selected: sel,
                onSelected: (_) => setState(() => _set = i),
                selectedColor: _colors[i],
                labelStyle: TextStyle(color: sel ? AppColors.washi : _colors[i], fontWeight: FontWeight.w700, fontSize: 12),
                side: BorderSide(color: _colors[i]),
                showCheckmark: false,
              ),
            );
          })),
        ),
        Expanded(
          child: LayoutBuilder(builder: (context, box) {
            final wide = _set == 0;
            final cols = wide ? (box.maxWidth >= 600 ? 7 : 5) : (box.maxWidth >= 600 ? 3 : 2);
            return GridView.builder(
              padding: EdgeInsets.fromLTRB(12, 4, 12, 80 + bottomInset(context)),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols, mainAxisSpacing: 8, crossAxisSpacing: 8, mainAxisExtent: wide ? 72 : 88),
              itemCount: items.length,
              itemBuilder: (context, i) => _cell(items[i], color, wide),
            );
          }),
        ),
      ]),
    );
  }

  Widget _cell(FrSound s, Color color, bool alphabet) {
    final aux = switch (_aux) { 0 => s.rd, 1 => '[${s.ipa}]', _ => '' };
    return InkWell(
      key: ValueKey('fr_sound_${s.key}'),
      onTap: () => showFrSoundSheet(context, s, color),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.washi,
          border: Border.all(color: color.withValues(alpha: 0.7)),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 4, offset: const Offset(1, 2))],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(alphabet ? '${s.key} ${s.key.toLowerCase()}' : s.key,
                style: TextStyle(fontSize: alphabet ? 22 : 17, fontWeight: FontWeight.w800, color: AppColors.sumi, height: 1.15)),
          ),
          if (!alphabet)
            Text(s.example.split(' · ').first, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.sumiLight)),
          if (aux.isNotEmpty)
            Text(aux, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}
