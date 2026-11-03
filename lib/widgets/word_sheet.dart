import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/platform.dart';
import '../core/theme.dart';
import '../services/tts_service.dart';
import '../services/word_service.dart';

/// 단어 시트 — 레마 칩을 누르면: 단어 · 한국어 뜻 · 영어 · 품사 · 절벽 구간 · 듣기.
Future<void> showWordSheet(BuildContext context, WordEntry w) => showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.washi,
      builder: (_) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, 20 + bottomInset(context)),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(w.word, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.sumi))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.beni.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text('${w.level} · ${w.rank}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.beni)),
              ),
              IconButton(onPressed: () => TtsService.instance.speak(w.word), icon: const Icon(Icons.volume_up, color: AppColors.beni)),
            ]),
            const SizedBox(height: 6),
            Text(w.ko, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.sumi)),
            const SizedBox(height: 4),
            Text('${w.en} · ${w.pos}', style: const TextStyle(fontSize: 13, color: AppColors.muted)),
            const SizedBox(height: 12),
            Container(height: 1, color: AppColors.line),
            const SizedBox(height: 10),
            Text(tr('성·수 · 관사 · 동사 활용은 준비 중'), style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          ]),
        ),
      ),
    );
