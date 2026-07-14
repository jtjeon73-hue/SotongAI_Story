# 소통AI스토리 (Sotong AI Story)

AI의 역사와 현재를 검증된 출처와 함께 소개하는 한국어 웹/앱 서비스입니다.
[소통웨어(SotongWare)](https://sotongware.com)가 제작·운영합니다.

- 서비스명: `소통AI스토리` (Sotong AI Story)
- 프레임워크: Flutter (Web 우선, 모바일/데스크톱 호환)
- 데이터: `assets/data/*.json`에 정적으로 포함된 검증된 콘텐츠
- 배포: Firebase Hosting (`sotongware-ai-story`)

## 목차

1. [주요 기능](#주요-기능)
2. [프로젝트 구조](#프로젝트-구조)
3. [로컬 개발 환경 설정](#로컬-개발-환경-설정)
4. [로컬 실행](#로컬-실행)
5. [테스트](#테스트)
6. [콘텐츠 데이터 검증](#콘텐츠-데이터-검증)
7. [빌드 및 Firebase 배포](#빌드-및-firebase-배포)
8. [브랜딩 아이콘 재생성](#브랜딩-아이콘-재생성)
9. [오류 제보](#오류-제보)
10. [콘텐츠 데이터 추가/수정 가이드](#콘텐츠-데이터-추가수정-가이드)

## 주요 기능

- **AI 역사 연대표**: 1950년대부터 현재까지 AI 역사의 주요 사건을 시간순으로 탐색
- **시대별 AI 변천사**: AI 발전을 여러 시대로 구분해 각 시기의 특징과 전환점을 설명
- **AI 핵심 개념**: 머신러닝, 딥러닝, LLM 등 핵심 개념을 비유와 함께 설명
- **AI 툴 탐색 / 인기·주목 AI / 숨은 보석 AI / AI 툴 비교**: 다양한 AI 도구를 카테고리·조건별로 탐색하고 최대 3개까지 나란히 비교
- **분야별 AI 활용 / 실전 AI 워크플로**: 업종별 활용사례와 단계별 실행 가이드
- **대한민국과 AI / 산업·농업 AI / AI 개발자 공간 / 안전·윤리·저작권**: 섹션 기반 심화 콘텐츠
- **AI 미래 전망**: 확인된 흐름부터 불확실한 시나리오까지 근거 수준을 구분해 전망
- **AI 용어사전**: 한글/영문 정렬 및 카테고리 필터를 갖춘 용어 사전
- **출처·검증센터**: 전체 출처 목록과 사이트 검증 현황, 오류 제보 채널
- **통합 검색 / 즐겨찾기**: 콘텐츠 전체를 대상으로 검색하고, 관심 콘텐츠를 즐겨찾기에 저장(SharedPreferences)
- **공유**: 링크 복사 / 제목+링크 복사 / (지원 브라우저에서) Web Share API
- **반응형 레이아웃**: 데스크톱은 접이식 사이드바(280px/76px), 모바일/태블릿은 드로어 내비게이션
- **접근성**: Semantics, 툴팁, 최소 터치 타겟(44x44) 등을 전반적으로 적용

## 프로젝트 구조

```
lib/
  app/                  # 앱 루트 위젯, go_router 설정, 반응형 셸
  core/
    constants/          # 라우트 경로, 메뉴, 외부 링크, 앱 전역 상수
    models/             # JSON ↔ Dart 모델 (null-safety 기본값 처리)
    repositories/       # ContentRepository: 전체 JSON 로드/캐시/검색
    services/           # 공유, 외부 링크 열기 등 서비스
    storage/            # SharedPreferences 기반 즐겨찾기 저장소
    utils/               # JSON 파싱, 날짜 포맷 유틸리티
  features/             # 기능별 페이지 (기능마다 하위 폴더)
  shared/
    layout/             # 반응형 브레이크포인트, 데스크톱/모바일 셸
    theme/               # 색상, 텍스트 스타일, ThemeData
    widgets/             # 카드, 배지, 필터칩, 검색창 등 공용 위젯
  main.dart              # 데이터 로딩 부트스트랩 + 앱 실행
assets/
  data/                  # 콘텐츠 JSON (sources, timeline, eras, ... )
                         # content_index.json: 홈 통계용 개수 캐시(지연 로딩 전 즉시 표시)
  branding/              # 서비스 아이콘 SVG
test/                    # 모델 파싱, 라우터, 반응형 레이아웃 테스트
tool/
  validate_content_data.dart  # 콘텐츠 데이터 정합성 검사 스크립트
```

## 로컬 개발 환경 설정

1. [Flutter SDK](https://docs.flutter.dev/get-started/install) 설치 (안정 채널 권장)
2. 저장소 클론 후 프로젝트 루트에서 의존성 설치:

   ```bash
   flutter pub get
   ```

3. (웹 개발 시) Chrome이 설치되어 있는지 확인합니다.

## 로컬 실행

```bash
# 웹으로 실행 (기본 포트는 Flutter가 자동 선택)
flutter run -d chrome

# 특정 포트로 실행
flutter run -d chrome --web-port=5000

# 연결된 모바일/데스크톱 기기로 실행
flutter devices
flutter run -d <device-id>
```

## 테스트

```bash
flutter test
```

`test/` 폴더에는 다음 테스트가 포함되어 있습니다.

- `model_parsing_test.dart`: `Source`, `TimelineEntry`, `AiTool` 등 모델의 JSON 파싱 및 null-safety 기본값 검증
- `router_test.dart`: go_router 라우트 경로 및 `:id` path parameter 해석 검증
- `responsive_layout_test.dart`: 데스크톱/태블릿/모바일 브레이크포인트 판별 로직 검증

## 콘텐츠 데이터 검증

콘텐츠 JSON을 수정한 뒤에는 아래 스크립트로 데이터 정합성을 검사하세요.

```bash
dart run tool/validate_content_data.dart
```

검사 항목:

- 각 파일 내 `id` 중복 여부
- 제목(`title`/`name`) 필드가 비어있는지 여부
- `sourceIds`가 `sources.json`에 실제로 존재하는 출처를 참조하는지
- 도구/워크플로 참조 필드(`recommendedToolIds`, `relatedWorkflowIds` 등)의 유효성
- `verifiedAt`/`lastVerified` 등 날짜 필드가 `yyyy-MM-dd` 형식인지

오류가 발견되면 종료 코드 1과 함께 문제 목록을 출력하므로, CI 파이프라인에 포함시켜 데이터 회귀를 방지할 수 있습니다.

## 빌드 및 Firebase 배포

1. 웹 빌드 생성:

   ```bash
   flutter build web
   ```

2. Firebase CLI로 배포 (사전에 `firebase login` 필요):

   ```bash
   firebase deploy --project sotongware-ai-story
   ```

배포 설정은 `firebase.json`(호스팅 대상: `build/web`)과 `.firebaserc`(기본 프로젝트: `sotongware-ai-story`)에 정의되어 있습니다.

## 브랜딩 아이콘 재생성

`assets/branding/sotong_ai_story_icon.svg`를 수정한 뒤 웹 파비콘/앱 아이콘 PNG를 다시 생성하려면:

```bash
cd tool
npm install
node render_ai_story_icons.js
```

생성된 이미지는 `web/icons/`, `web/favicon.png` 등에 반영됩니다.

## 오류 제보

앱 내 **출처·검증센터** 또는 **소통웨어 소개** 페이지에서 오류 제보 버튼을 눌러 메일 앱을 열 수 있습니다. 수동으로 보낼 경우:

- 수신: `sotongware@naver.com`
- 제목: `[소통AI스토리 오류 제보]`

## 콘텐츠 데이터 추가/수정 가이드

1. `assets/data/` 내 해당 JSON 파일에 항목을 추가하거나 수정합니다. 각 항목은 고유한 `id`를 가져야 하며, 가능한 모든 `sourceIds`는 `sources.json`에 실제로 존재해야 합니다.
2. `dart run tool/validate_content_data.dart`로 정합성을 검사합니다.
3. 관련 모델(`lib/core/models/`)의 필드 이름과 JSON 키가 일치하는지 확인합니다. 새 필드를 추가했다면 모델과 `ContentRepository`도 함께 갱신하세요.
4. `flutter test`와 `flutter analyze`를 실행해 회귀가 없는지 확인합니다.
5. 콘텐츠에 큰 변경이 있다면 `assets/data/site_updates.json`의 `contentLastVerified`와 `assets/data/content_index.json`의 개수/최근 검증일을 함께 갱신하는 것을 권장합니다. 검증 통계(검증 완료/부분 검증/검증 필요 등)는 더 이상 수동 입력값이 아니라 `ContentRepository.computeVerificationStats()`가 각 콘텐츠의 `status` 필드를 스캔해 자동으로 계산합니다.
