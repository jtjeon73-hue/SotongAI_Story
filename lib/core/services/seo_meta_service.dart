import 'seo/seo_meta_applier_stub.dart'
    if (dart.library.html) 'seo/seo_meta_applier_web.dart' as applier;
import 'seo/seo_meta_info.dart';

export 'seo/seo_meta_info.dart';

/// 클라이언트 사이드 내비게이션 시 `document.title`/메타 태그를 갱신하는
/// 서비스 (웹 전용, 비웹 플랫폼에서는 아무 동작도 하지 않음).
///
/// go_router의 `redirect` 콜백에서 매 라우트 전환마다 [updateForPath]를
/// 호출해 사용한다. 상세 페이지(`/tools/:id` 등)처럼 콘텐츠별로 완전히
/// 고유한 제목이 필요한 경로는, 빌드 시점에 `tool/generate_seo_pages.dart`가
/// 생성하는 정적 HTML이 검색엔진 크롤러 관점의 "진짜" 메타데이터를 담당하고,
/// 이 서비스는 그 사이 클라이언트 내비게이션 중 보이는 탭 제목/공유
/// 미리보기를 그럴듯하게 맞춰주는 보조 역할을 한다.
class SeoMetaService {
  SeoMetaService._();

  static const String baseUrl = 'https://sotongware-ai-story.web.app';
  static const String siteTitleSuffix = ' | 소통AI스토리';
  static const String defaultDescription =
      'AI의 역사와 변천, 핵심 개념, 활용 도구, 산업·농업 적용, 실전 워크플로와 미래 전망을 '
      '체계적으로 제공하는 소통웨어 공개 AI 지식 플랫폼입니다.';

  /// 경로별 고정 제목/설명. 상세 페이지(`:id` 포함 경로)는 여기 없으면
  /// 상위 섹션 제목을 재사용하는 일반적인 문구로 대체한다.
  static const Map<String, ({String title, String description})> _routes = {
    '/': (
      title: '소통AI스토리 | AI 역사·도구·활용·미래 지식 플랫폼',
      description: defaultDescription,
    ),
    '/timeline': (
      title: 'AI 역사 연대표$siteTitleSuffix',
      description: '1950년부터 현재까지 AI 역사의 주요 사건을 시간순으로 살펴봅니다.',
    ),
    '/eras': (
      title: '시대별 AI 변천사$siteTitleSuffix',
      description: 'AI 발전을 여러 시대로 구분해 각 시기의 특징과 전환점을 설명합니다.',
    ),
    '/concepts': (
      title: 'AI 핵심 개념$siteTitleSuffix',
      description: '머신러닝, 딥러닝, LLM 등 AI의 핵심 개념을 쉽게 풀어 설명합니다.',
    ),
    '/tools': (
      title: 'AI 툴 탐색$siteTitleSuffix',
      description: '다양한 AI 도구를 카테고리와 조건별로 찾아봅니다.',
    ),
    '/tool-compare': (
      title: 'AI 툴 비교$siteTitleSuffix',
      description: '최대 3개의 AI 도구를 나란히 비교해 봅니다.',
    ),
    '/use-cases': (
      title: '분야별 AI 활용$siteTitleSuffix',
      description: '업종·직무별로 AI를 실제로 활용하는 사례를 소개합니다.',
    ),
    '/popular-ai': (
      title: '인기·주목 AI$siteTitleSuffix',
      description: '현재 가장 널리 쓰이고 주목받는 AI 도구를 모았습니다.',
    ),
    '/hidden-gems': (
      title: '숨은 보석 AI$siteTitleSuffix',
      description: '잘 알려지지 않았지만 유용한 AI 도구를 소개합니다.',
    ),
    '/workflows': (
      title: '실전 AI 워크플로$siteTitleSuffix',
      description: '실제 업무에 AI를 단계별로 적용하는 워크플로를 안내합니다.',
    ),
    '/korea-ai': (
      title: '대한민국과 AI$siteTitleSuffix',
      description: '한국의 AI 정책과 국내 기업의 AI 서비스를 다룹니다.',
    ),
    '/industry-ai': (
      title: '산업·농업 AI$siteTitleSuffix',
      description: '제조·농업 등 다양한 산업 분야의 AI 활용 현황을 소개합니다.',
    ),
    '/developer': (
      title: 'AI 개발자 공간$siteTitleSuffix',
      description: 'API, 프롬프트 엔지니어링, RAG 등 개발자를 위한 정보를 제공합니다.',
    ),
    '/safety': (
      title: '안전·윤리·저작권$siteTitleSuffix',
      description: 'AI 사용 시 유의해야 할 안전, 윤리, 저작권 이슈를 다룹니다.',
    ),
    '/future': (
      title: 'AI 미래 전망$siteTitleSuffix',
      description: '앞으로의 AI 발전 방향과 준비할 점을 전망합니다.',
    ),
    '/glossary': (
      title: 'AI 용어사전$siteTitleSuffix',
      description: 'AI 관련 용어를 한글·영문으로 찾아볼 수 있습니다.',
    ),
    '/sources': (
      title: '출처·검증센터$siteTitleSuffix',
      description: '콘텐츠에 사용된 출처와 검증 상태를 확인합니다.',
    ),
    '/about': (
      title: '소통웨어 소개$siteTitleSuffix',
      description: '이 서비스를 만든 소통웨어를 소개합니다.',
    ),
  };

  /// 검색엔진에 노출하지 않을 경로(개인화·일회성 페이지).
  static const Set<String> _noIndexPrefixes = {'/search', '/favorites'};

  static const Map<String, String> _sectionLabelByPrefix = {
    '/timeline': '연대표 상세',
    '/eras': '시대 상세',
    '/concepts': '핵심 개념 상세',
    '/tools': 'AI 툴 상세',
    '/use-cases': '활용사례 상세',
    '/workflows': '워크플로 상세',
  };

  /// [path]에 해당하는 [SeoMetaInfo]를 계산해 문서 메타데이터를 갱신한다.
  ///
  /// go_router의 `state.uri.path`를 그대로 넘기면 된다. 비웹 플랫폼에서는
  /// 스텁 구현이 아무 것도 하지 않으므로 안전하게 호출할 수 있다.
  static void updateForPath(String path) {
    applier.applySeoMeta(resolve(path));
  }

  /// 경로에 대한 [SeoMetaInfo]를 계산한다(테스트에서 직접 검증할 수 있도록
  /// DOM 적용과 분리되어 있다).
  static SeoMetaInfo resolve(String path) {
    final normalized = path.isEmpty ? '/' : path;
    final noIndex = _noIndexPrefixes.any(
      (prefix) => normalized == prefix || normalized.startsWith('$prefix/'),
    );

    final exact = _routes[normalized];
    if (exact != null) {
      return SeoMetaInfo(
        title: exact.title,
        description: exact.description,
        canonicalUrl: '$baseUrl$normalized',
        noIndex: noIndex,
      );
    }

    for (final entry in _sectionLabelByPrefix.entries) {
      if (normalized.startsWith('${entry.key}/')) {
        return SeoMetaInfo(
          title: '${entry.value}$siteTitleSuffix',
          description: defaultDescription,
          canonicalUrl: '$baseUrl$normalized',
          noIndex: noIndex,
        );
      }
    }

    return SeoMetaInfo(
      title: '페이지 정보$siteTitleSuffix',
      description: defaultDescription,
      canonicalUrl: '$baseUrl$normalized',
      noIndex: noIndex,
    );
  }
}
