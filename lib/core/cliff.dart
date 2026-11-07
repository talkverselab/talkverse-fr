/// 프랑스어 절벽 값 — 코드 한 곳(docs/CLIFF_FR.md, 2026-11-03 실측). 누적 55/60/70/80% 에 처음 닿는 순위가 R1~R4 의 끝, 그 밖은 R5.
/// R5 는 2,000위에서 끊는다(사용자 지시 2026-11-07). 2,000위 누적 = 2,500위 89.7% 에서 2,001~2,500위 몫(약 0.9%)을 뺀 값.
const List<int> kWordCliffs = [44, 61, 146, 491];
const int kWordCap = 2000;
const double kWordCapPct = 88.8;

String regionOf(int rank) {
  for (var i = 0; i < kWordCliffs.length; i++) {
    if (rank <= kWordCliffs[i]) return 'R${i + 1}';
  }
  return 'R5';
}
