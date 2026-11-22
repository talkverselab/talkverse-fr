import 'package:flutter_test/flutter_test.dart';
import 'package:french_universe/services/dialogue_audio.dart';

void main() {
  test('녹음 글이 원고와 같은 말이면 녹음, 대사를 고쳤으면 TTS', () {
    expect(audioFitsScript("Salut ! Ça va ?", "Salut ! Ça va ?"), isTrue);
    expect(audioFitsScript("salut ça va", "Salut ! Ça va ?"), isTrue); // 문장부호·대소문자 무시
    expect(audioFitsScript("Moi, c'est Léa.", "Moi, c'est {name}."), isTrue); // 이름 자리는 아무 글이나
    expect(audioFitsScript("Bonjour, ça va ?", "Salut ! Ça va ?"), isFalse); // 다시 쓴 대사
  });
}
