/// go_router 라우트 경로 상수 모음.
///
/// 문자열 리터럴 중복을 막고, 네비게이션·라우터 설정에서 동일한 값을 참조한다.
class RoutePaths {
  RoutePaths._();

  static const String home = '/';
  static const String timeline = '/timeline';
  static const String timelineDetail = '/timeline/:id';
  static const String eras = '/eras';
  static const String erasDetail = '/eras/:id';
  static const String concepts = '/concepts';
  static const String conceptsDetail = '/concepts/:id';
  static const String tools = '/tools';
  static const String toolsDetail = '/tools/:id';
  static const String toolCompare = '/tool-compare';
  static const String useCases = '/use-cases';
  static const String useCasesDetail = '/use-cases/:id';
  static const String popularAi = '/popular-ai';
  static const String hiddenGems = '/hidden-gems';
  static const String workflows = '/workflows';
  static const String workflowsDetail = '/workflows/:id';
  static const String koreaAi = '/korea-ai';
  static const String industryAi = '/industry-ai';
  static const String developer = '/developer';
  static const String safety = '/safety';
  static const String future = '/future';
  static const String glossary = '/glossary';
  static const String sources = '/sources';
  static const String about = '/about';
  static const String favorites = '/favorites';
  static const String search = '/search';

  /// [id]에 대한 타임라인 상세 경로를 생성한다.
  static String timelineDetailOf(String id) => '/timeline/$id';

  /// [id]에 대한 시대 상세 경로를 생성한다.
  static String erasDetailOf(String id) => '/eras/$id';

  /// [id]에 대한 개념 상세 경로를 생성한다.
  static String conceptsDetailOf(String id) => '/concepts/$id';

  /// [id]에 대한 도구 상세 경로를 생성한다.
  static String toolsDetailOf(String id) => '/tools/$id';

  /// [id]에 대한 활용사례 상세 경로를 생성한다.
  static String useCasesDetailOf(String id) => '/use-cases/$id';

  /// [id]에 대한 워크플로 상세 경로를 생성한다.
  static String workflowsDetailOf(String id) => '/workflows/$id';
}
