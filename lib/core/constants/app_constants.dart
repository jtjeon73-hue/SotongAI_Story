/// 앱 전역에서 사용하는 정적 상수 모음.
///
/// 서비스 이름, 문의 이메일, 파이어베이스 관련 값, 레이아웃 치수 등을
/// 한 곳에서 관리해 다른 코드에서 하드코딩을 피할 수 있도록 한다.
class AppConstants {
  AppConstants._();

  // 서비스 정보
  static const String appName = '소통AI스토리';
  static const String appNameEn = 'Sotong AI Story';
  static const String appSlogan = 'AI의 역사와 현재, 검증된 이야기로 소통합니다';
  static const String operatorName = '소통웨어(SotongWare)';

  // 문의/제보
  static const String contactEmail = 'sotongware@naver.com';
  static const String errorReportSubject = '[소통AI스토리 오류 제보]';

  // Firebase / 배포
  static const String firebaseProjectId = 'sotongware-ai-story';
  static const String firebaseHostingUrl =
      'https://sotongware-ai-story.web.app';

  // 자산 경로
  static const String dataAssetsPath = 'assets/data';
  static const String brandingIconSvg =
      'assets/branding/sotong_ai_story_icon.svg';

  // 반응형 레이아웃 치수
  static const double desktopBreakpoint = 1100;
  static const double tabletBreakpoint = 720;
  static const double sidebarExpandedWidth = 280;
  static const double sidebarCollapsedWidth = 76;
  static const double contentMaxWidth = 1280;
  static const double headerHeight = 96;

  // 접근성 관련
  static const double minTouchTargetSize = 44;

  // 즐겨찾기 카테고리 키 (SharedPreferences 저장용)
  static const String favTimeline = 'timeline';
  static const String favTools = 'tools';
  static const String favWorkflows = 'workflows';
  static const String favConcepts = 'concepts';

  // 도구 비교 최대 개수
  static const int maxCompareTools = 3;

  // 최근 검색어 (SharedPreferences 저장용, 로컬 기기에만 저장)
  static const String recentSearchesKey = 'recent_searches';
  static const int maxRecentSearches = 8;

  // 애니메이션 지속 시간
  static const Duration shortAnimation = Duration(milliseconds: 180);
  static const Duration mediumAnimation = Duration(milliseconds: 280);
}
