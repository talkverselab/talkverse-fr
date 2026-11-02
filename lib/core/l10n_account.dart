// 계정·결제 화면 문구 — 한국어 키 → 영어 / 일본어 / 중국어 (Talkverse ID, 2026-11-02).
// 공용 사전(l10n_dict.dart, 키트 소유)과 따로 둔다. 키트 사전에 같은 문구가 들어오면 그쪽이 먼저 쓰인다.
// ignore_for_file: lines_longer_than_80_chars

import 'l10n.dart';

const Map<String, String> _en = {
  '계정': 'Account',
  '로그인': 'Sign in',
  '로그아웃': 'Sign out',
  '계정 삭제': 'Delete account',
  '이름 없음': 'No name',
  'Talkverse 계정': 'Talkverse account',
  'Talkverse 계정 하나로 모든 앱에서': 'One Talkverse account for every app',
  '로그인은 선택입니다. 계정 하나로 프랑스어유니버스와 Talkverse 언어 앱, talkverse.uk 를 함께 씁니다.':
      'Signing in is optional. One account works across French Universe, the Talkverse language apps and talkverse.uk.',
  '{0} 로그인은 준비 중입니다. 다른 방법으로 로그인해 주세요.': '{0} sign-in is coming soon. Please use another method.',
  '로그인하지 못했습니다. 잠시 후 다시 시도해 주세요.': 'Sign-in failed. Please try again.',
  '이메일 또는 비밀번호가 맞지 않습니다.': 'Email or password is incorrect.',
  '이메일로 로그인 (심사·테스트용)': 'Sign in with email (review/testing)',
  '이메일': 'Email',
  '비밀번호': 'Password',
  '네이버': 'Naver',
  '카카오': 'Kakao',
  'Google로 로그인': 'Sign in with Google',
  '카카오 로그인': 'Sign in with Kakao',
  '네이버 로그인': 'Sign in with Naver',
  'Apple로 로그인': 'Sign in with Apple',
  '계정을 삭제할까요?': 'Delete your account?',
  'Talkverse 계정과 이름·이메일·로그인 정보가 지워지고 모든 기기에서 로그아웃됩니다. 이 기기의 학습 기록은 그대로 남습니다. 되돌릴 수 없습니다.':
      'Your Talkverse account, name, email and sign-in methods will be erased and you will be signed out on every device. Study progress on this device stays. This cannot be undone.',
  '취소': 'Cancel',
  '삭제': 'Delete',
  '삭제하지 못했습니다. 네트워크를 확인하고 다시 시도해 주세요.': 'Could not delete. Check your connection and try again.',
  '평생 이용권': 'Lifetime Pass',
  '보유 중 — 감사합니다': 'Owned — thank you',
  '한 번 결제로 앞으로의 유료 과정까지': 'One payment, including future paid courses',
  '구매 복원': 'Restore purchases',
  '이전 구매 복원': 'Restore purchases',
  '확인 중…': 'Checking…',
  '복원했습니다': 'Restored',
  '복원할 구매가 없습니다': 'Nothing to restore',
  '복원할 구매가 없습니다.': 'No purchases to restore.',
  '이전에 산 평생 이용권을 이 기기에서 다시 엽니다': 'Unlock a lifetime pass you bought before',
  '한 번 결제 · 구독 아님 · 평생': 'One-time · not a subscription · forever',
  '앞으로 추가되는 유료 과정을 추가 결제 없이': 'Paid courses added later, at no extra cost',
  '이 기기와 Talkverse 계정에 이용권 기록(로그인 시 다른 기기에서도)': 'Saved on this device and to your Talkverse account (other devices when signed in)',
  '지금 있는 모든 기능은 계속 무료': 'Everything available now stays free',
  '결제를 마치지 못했습니다. 다시 시도해 주세요.': 'The purchase did not complete. Please try again.',
  '스토어에 연결하는 중…': 'Connecting to the store…',
  '평생 이용권 구매 · {0}': 'Buy Lifetime Pass · {0}',
  '스토어 가격 확인 중': 'Checking store price',
  '로그인하면 다른 기기에서도 이용권이 열립니다 (선택)': 'Sign in to use the pass on other devices (optional)',
  '로그인됨 — 구매는 Talkverse 계정에 기록되어 다른 기기에서도 열립니다.': 'Signed in — the purchase is saved to your Talkverse account and opens on other devices.',
  '결제는 App Store / Google Play 에서 처리됩니다. 표시 가격은 스토어 가격을 따르며 세금이 포함될 수 있습니다.':
      'Payment is handled by the App Store / Google Play. The price shown follows the store price and may include tax.',
};

const Map<String, String> _ja = {
  '계정': 'アカウント',
  '로그인': 'ログイン',
  '로그아웃': 'ログアウト',
  '계정 삭제': 'アカウント削除',
  '이름 없음': '名前なし',
  'Talkverse 계정': 'Talkverse アカウント',
  'Talkverse 계정 하나로 모든 앱에서': 'Talkverse アカウントひとつで全アプリに',
  '로그인은 선택입니다. 계정 하나로 프랑스어유니버스와 Talkverse 언어 앱, talkverse.uk 를 함께 씁니다.':
      'ログインは任意です。ひとつのアカウントでフランス語ユニバース、Talkverse の語学アプリ、talkverse.uk を使えます。',
  '{0} 로그인은 준비 중입니다. 다른 방법으로 로그인해 주세요.': '{0} ログインは準備中です。別の方法でログインしてください。',
  '로그인하지 못했습니다. 잠시 후 다시 시도해 주세요.': 'ログインできませんでした。しばらくしてからもう一度お試しください。',
  '이메일 또는 비밀번호가 맞지 않습니다.': 'メールアドレスまたはパスワードが違います。',
  '이메일로 로그인 (심사·테스트용)': 'メールでログイン（審査・テスト用）',
  '이메일': 'メールアドレス',
  '비밀번호': 'パスワード',
  '네이버': 'NAVER',
  '카카오': 'Kakao',
  'Google로 로그인': 'Google でログイン',
  '카카오 로그인': 'Kakao でログイン',
  '네이버 로그인': 'NAVER でログイン',
  'Apple로 로그인': 'Apple でサインイン',
  '계정을 삭제할까요?': 'アカウントを削除しますか？',
  'Talkverse 계정과 이름·이메일·로그인 정보가 지워지고 모든 기기에서 로그아웃됩니다. 이 기기의 학습 기록은 그대로 남습니다. 되돌릴 수 없습니다.':
      'Talkverse アカウントと名前・メール・ログイン情報が削除され、すべての端末でログアウトします。この端末の学習記録は残ります。元に戻せません。',
  '취소': 'キャンセル',
  '삭제': '削除',
  '삭제하지 못했습니다. 네트워크를 확인하고 다시 시도해 주세요.': '削除できませんでした。通信を確認してもう一度お試しください。',
  '평생 이용권': '永久利用券',
  '보유 중 — 감사합니다': '購入済み — ありがとうございます',
  '한 번 결제로 앞으로의 유료 과정까지': '一度の支払いで今後の有料コースまで',
  '구매 복원': '購入を復元',
  '이전 구매 복원': '購入を復元',
  '확인 중…': '確認中…',
  '복원했습니다': '復元しました',
  '복원할 구매가 없습니다': '復元する購入はありません',
  '복원할 구매가 없습니다.': '復元する購入はありません。',
  '이전에 산 평생 이용권을 이 기기에서 다시 엽니다': '以前購入した永久利用券をこの端末で有効にします',
  '한 번 결제 · 구독 아님 · 평생': '一回払い・サブスクではありません・永久',
  '앞으로 추가되는 유료 과정을 추가 결제 없이': '今後追加される有料コースも追加料金なし',
  '이 기기와 Talkverse 계정에 이용권 기록(로그인 시 다른 기기에서도)': 'この端末と Talkverse アカウントに記録（ログインすると他の端末でも）',
  '지금 있는 모든 기능은 계속 무료': '今ある機能はすべて引き続き無料',
  '결제를 마치지 못했습니다. 다시 시도해 주세요.': '支払いが完了しませんでした。もう一度お試しください。',
  '스토어에 연결하는 중…': 'ストアに接続中…',
  '평생 이용권 구매 · {0}': '永久利用券を購入 · {0}',
  '스토어 가격 확인 중': 'ストア価格を確認中',
  '로그인하면 다른 기기에서도 이용권이 열립니다 (선택)': 'ログインすると他の端末でも使えます（任意）',
  '로그인됨 — 구매는 Talkverse 계정에 기록되어 다른 기기에서도 열립니다.': 'ログイン済み — 購入は Talkverse アカウントに記録され、他の端末でも使えます。',
  '결제는 App Store / Google Play 에서 처리됩니다. 표시 가격은 스토어 가격을 따르며 세금이 포함될 수 있습니다.':
      '支払いは App Store / Google Play で処理されます。表示価格はストア価格に従い、税が含まれる場合があります。',
};

const Map<String, String> _zh = {
  '계정': '账户',
  '로그인': '登录',
  '로그아웃': '退出登录',
  '계정 삭제': '删除账户',
  '이름 없음': '无名称',
  'Talkverse 계정': 'Talkverse 账户',
  'Talkverse 계정 하나로 모든 앱에서': '一个 Talkverse 账户通用所有应用',
  '로그인은 선택입니다. 계정 하나로 프랑스어유니버스와 Talkverse 언어 앱, talkverse.uk 를 함께 씁니다.':
      '登录是可选的。一个账户可同时用于法语宇宙、Talkverse 语言应用和 talkverse.uk。',
  '{0} 로그인은 준비 중입니다. 다른 방법으로 로그인해 주세요.': '{0} 登录即将推出，请使用其他方式登录。',
  '로그인하지 못했습니다. 잠시 후 다시 시도해 주세요.': '登录失败，请稍后再试。',
  '이메일 또는 비밀번호가 맞지 않습니다.': '邮箱或密码不正确。',
  '이메일로 로그인 (심사·테스트용)': '使用邮箱登录（审核·测试用）',
  '이메일': '邮箱',
  '비밀번호': '密码',
  '네이버': 'Naver',
  '카카오': 'Kakao',
  'Google로 로그인': '使用 Google 登录',
  '카카오 로그인': '使用 Kakao 登录',
  '네이버 로그인': '使用 Naver 登录',
  'Apple로 로그인': '通过 Apple 登录',
  '계정을 삭제할까요?': '要删除账户吗？',
  'Talkverse 계정과 이름·이메일·로그인 정보가 지워지고 모든 기기에서 로그아웃됩니다. 이 기기의 학습 기록은 그대로 남습니다. 되돌릴 수 없습니다.':
      '将删除 Talkverse 账户及姓名、邮箱、登录信息，并在所有设备上退出登录。本设备的学习记录会保留。此操作无法撤销。',
  '취소': '取消',
  '삭제': '删除',
  '삭제하지 못했습니다. 네트워크를 확인하고 다시 시도해 주세요.': '删除失败，请检查网络后重试。',
  '평생 이용권': '终身使用券',
  '보유 중 — 감사합니다': '已拥有 — 谢谢',
  '한 번 결제로 앞으로의 유료 과정까지': '一次付款，包含今后的付费课程',
  '구매 복원': '恢复购买',
  '이전 구매 복원': '恢复购买',
  '확인 중…': '确认中…',
  '복원했습니다': '已恢复',
  '복원할 구매가 없습니다': '没有可恢复的购买',
  '복원할 구매가 없습니다.': '没有可恢复的购买。',
  '이전에 산 평생 이용권을 이 기기에서 다시 엽니다': '在本设备上重新启用以前购买的终身使用券',
  '한 번 결제 · 구독 아님 · 평생': '一次付款 · 非订阅 · 终身',
  '앞으로 추가되는 유료 과정을 추가 결제 없이': '今后新增的付费课程无需额外付费',
  '이 기기와 Talkverse 계정에 이용권 기록(로그인 시 다른 기기에서도)': '记录在本设备和 Talkverse 账户中（登录后其他设备也可用）',
  '지금 있는 모든 기능은 계속 무료': '现有的所有功能继续免费',
  '결제를 마치지 못했습니다. 다시 시도해 주세요.': '付款未完成，请重试。',
  '스토어에 연결하는 중…': '正在连接商店…',
  '평생 이용권 구매 · {0}': '购买终身使用券 · {0}',
  '스토어 가격 확인 중': '正在确认商店价格',
  '로그인하면 다른 기기에서도 이용권이 열립니다 (선택)': '登录后其他设备也可使用（可选）',
  '로그인됨 — 구매는 Talkverse 계정에 기록되어 다른 기기에서도 열립니다.': '已登录 — 购买记录在 Talkverse 账户中，其他设备也可使用。',
  '결제는 App Store / Google Play 에서 처리됩니다. 표시 가격은 스토어 가격을 따르며 세금이 포함될 수 있습니다.':
      '付款由 App Store / Google Play 处理。显示价格以商店价格为准，可能含税。',
};

/// 계정·결제 화면 문구. 공용 사전에 있으면 그것을, 없으면 이 파일의 표를, 그것도 없으면 한국어.
String ta(String ko) {
  final viaKit = tr(ko);
  if (viaKit != ko) return viaKit;
  return switch (AppLangPrefs.lang.value) {
        AppLang.ko => null,
        AppLang.en => _en[ko],
        AppLang.ja => _ja[ko],
        AppLang.zh => _zh[ko],
      } ??
      ko;
}

/// 보간 문구 — `{0}` 자리에 값을 채운다.
String taf(String template, List<Object?> args) {
  var s = ta(template);
  for (var i = 0; i < args.length; i++) {
    s = s.replaceAll('{$i}', '${args[i]}');
  }
  return s;
}
