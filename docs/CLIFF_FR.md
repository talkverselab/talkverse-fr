# 프랑스어 절벽 구간 — 레마 기준 실측 (2026-11-03, 사용자 지시)

옛 값(웹·문어 혼합 표면형) **55% 102 · 60% 155 · 70% 385 · 80% 1,104** 를 폐기하고, 스페인어·독일어·러시아어앱과 같은 절차로 다시 셌다.

## 방법
- 코퍼스: 프랑스에서 만든 영화·드라마(번역 더빙·외국 작품 제외) 자막 25,390개, 문장 2,392만, **토큰 125,880,443개**(러시아어앱 세션이 만든 자국 작품 레마+품사 집계를 받아 씀).
- 레마 단위: 같은 원형의 품사별 행을 합산, 활용형·동사+대명사 결합(`passe-moi`→passer, `est-elle`→être, `veux`→vouloir, `étai`→être 등)을 원형으로 합침.
- 제외: 사전에 없는 가짜 원형은 바른 원형으로 고치거나(`pèr`→père, `voulai`→vouloir 등) 버림, 사람·지명, 영어 낱말, 자막 기호·조각(한 글자 등). 숫자 낱말(deux, trois…)은 낱말로 남김.
- 덮는 비율 = 누적 빈도 ÷ 전체 토큰.

## 결과
| 구간 | 덮는 비율 | 레마 수 | 경계 레마 |
|---|---|---:|---|
| R1 | 55% | **44** | moi |
| R2 | 60% | **61** | où |
| R3 | 70% | **146** | ok |
| R4 | 80% | **491** | million |

- 상위 2,500 레마가 덮는 비율: **89.7%** (정리 뒤 레마 4,228종 중).
- 옛 값 대비 R1: 102 → **44 (−58)**. 레마로 세면 활용형이 하나로 모여 앞쪽이 줄어든다(스페인어 57→45, 독일어 153→89 와 같은 방향).

## R1 레마 44개
le de je ce un être que pas avoir vous ne tu il à et aller cela te faire me on pour en mon lui tout se pouvoir mais dire qui vouloir non dans son nous savoir bien si plus oui avec voir moi

## R2 (45~61)
au y devoir là ton quoi comme votre venir sur toi bon rien parler ici pourquoi où

## 남은 일
- 그림용 단어 목록 `talkversehanja` `talkverse_art/words/fr.csv`(c94fcc1)는 빈도 라이브러리 순위로 만든 것 — 이 레마 순위로 다시 만들지 결정 필요(스페인어·독일어는 레마 순위로 교체함).
- 활용형 정리는 상위 약 700위까지 손으로 확인했다. 그 아래 꼬리에는 활용형이 일부 남아 있을 수 있다(80% 경계 491위에는 영향 작음).
