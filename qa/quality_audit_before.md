# 소통AI스토리 2차 고도화 — 수정 전 품질 기준

기록일: 2026-07-14  
Git 커밋: `8d0a7adeb6148a654383d5608df25d569b5e7f09` (`Build and deploy Sotong AI Story platform`)  
브랜치: `main`  
원격: `https://github.com/jtjeon73-hue/SotongAI_Story.git`  
Firebase use: `sotongware-ai-story`

## 검사 결과

| 항목 | 결과 |
|------|------|
| `dart format --set-exit-if-changed` | 통과 (exit 0) |
| `flutter analyze` | No issues found |
| `flutter test` | 31개 전부 통과 |
| `dart run tool/validate_content_data.dart` | 오류 0 |

## 데이터 개수 (수정 전)

| 데이터 | 개수 |
|--------|------|
| timeline | 42 (연도 1950–2024) |
| eras | 10 |
| concepts | 35 |
| ai_tools | 49 (active 47, verificationRequired 2) |
| workflows | 18 |
| use_cases | 24 |
| glossary | 51 |
| future_trends | 18 |
| sources | 92 |

## 시작 시 로딩 구조

- `main.dart` → `ContentRepository.loadAll()`로 **14개 JSON 전체 eager 로드** 후 앱 표시
- 라우트별 지연 로딩 없음
- 한 번 로드 후 메모리 캐시

## Sitemap / SEO

- 정적 SEO 페이지: **1** (`web/index.html`만, 전 경로 동일 메타)
- sitemap URL 개수: **18** (상위 메뉴만, 상세 `:id` 없음)
- `lastmod` 전부 `2026-07-14` 고정
- 동적 document.title / OG 갱신 없음

## 현재 AI 툴 필터

- 카테고리 칩
- 무료 이용 가능 (pricingType free/freemium)
- 한국어 지원 (bool)
- 텍스트 검색 (name, description만)

미구현: 가격 형태, 플랫폼, API, 로컬, 파일업로드, 대상사용자, 검증상태, 검증기간, URL query 보존, 정렬 다종

## 검증 상태 (콘텐츠 status 기준 대략)

- `site_updates.pendingVerificationCount` = **하드코딩 3**
- tools: verificationRequired 2 → ContentStatus에 미매핑 시 `unknown`으로 표시될 수 있음
- timeline: verified 다수, partiallyVerified 일부
- future_trends: 전부 forecast

## 기존 문제점 (코드·감사로 확인)

1. 사이드바/배너에 Material `Icons.hub` 사용 — 전용 SVG 미적용
2. 메뉴 18개 플랫 목록 — 그룹 없음
3. 전체 JSON 일괄 로딩 — 초기 체감 지연 가능
4. ResponsiveGrid 고정 `childAspectRatio` — 카드 내용 잘림 가능
5. AI 툴 bool 단순화 (koreanSupport/api/local) — unknown과 false 미구분
6. fieldEvidence(필드별 출처) 없음
7. 검증 통계 하드코딩
8. 출처 역참조·출처센터 검색/필터 부족
9. sitemap 상세 URL 없음, SEO 페이지별 메타 없음
10. firebase.json headers/캐시 정책 없음
11. 검색: future/sources 미포함, 타입 필터·하이라이트·최근검색 부족
12. 타임라인 최신 2024년까지 — 2025~2026 미수록
13. `external_links.dart`에 `https://sotongware.com/control` (소통총관제 성격 링크) 존재 — **공개 연결 금지**
14. Firebase 프로모 주소와 `sotongware.com/*` 불일치 가능성

## 스크린샷 목록 (수정 전)

- 수정 전 자동 스크린샷은 본 audit 시점 미수집
- 실제 브라우저 시각 검사는 `flutter run`/배포 URL 기준으로 수정 과정에서 수행 예정
- 경로: `qa/screenshots/before/` (생성 시)

## 금지 프로젝트 보호

배포 대상은 `sotongware-ai-story`만. `sotongware-control` 등은 배포 금지 목록으로만 유지.
