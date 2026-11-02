import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'data/db/app_database.dart';
import 'data/db/seed_loader.dart';
import 'screens/main_screen.dart';
import 'services/ko_reading.dart';
import 'core/l10n.dart';
import 'data/account.dart';
import 'data/purchase.dart';

late final AppDatabase appDb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  appDb = AppDatabase();
  await SeedLoader(appDb).seedIfNeeded();
  await KoReadingPrefs.load();
  await AppLangPrefs.load();
  Account.load(); // Talkverse ID — 저장된 로그인 표시 + 뒤에서 토큰 갱신(기다리지 않음). 로그인은 선택
  Purchase.configure({'fr': ('com.talkverse.frenchUniverse.lifetime', 'lang_fr')}); // 평생 이용권(스토어)
  runApp(const FrenchUniverseApp());
}

class FrenchUniverseApp extends StatelessWidget {
  const FrenchUniverseApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 표시 언어가 바뀌면 key 가 바뀌어 앱 전체가 새로 그려진다 (홈으로 돌아감).
    return ValueListenableBuilder<AppLang>(
      valueListenable: AppLangPrefs.lang,
      builder: (context, lang, _) => MaterialApp(
        key: ValueKey(lang),
        title: tr('프랑스어유니버스'),
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.light,
        // 아이폰 Dynamic Type·갤럭시 글자 크기 설정이 커도 타일이 깨지지 않게 1.2배까지만
        builder: (context, child) {
          final mq = MediaQuery.of(context);
          return MediaQuery(
            data: mq.copyWith(
              textScaler: mq.textScaler.clamp(maxScaleFactor: 1.2),
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const MainScreen(),
      ),
    );
  }
}
