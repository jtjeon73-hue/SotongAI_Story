// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// `flutter build web` 완료 후, 각 라우트별로 고유한 `<title>`/메타 태그/
/// JSON-LD를 가진 정적 `index.html`을 생성하는 독립 실행 스크립트.
///
/// 실행: `dart run tool/generate_seo_pages.dart` (반드시 `flutter build web`
/// 이후, `build/web` 디렉터리가 존재하는 상태에서 실행)
///
/// 배경: 이 앱은 클라이언트 사이드 렌더링 SPA라서 검색엔진 크롤러가 처음
/// 받는 HTML은 항상 같은 `index.html`이다. 크롤러가 라우트별로 다른
/// 제목·설명·정규 URL을 보게 하려면, 빌드 결과물에 `<경로>/index.html`
/// 형태의 정적 파일을 미리 만들어 두어야 한다.
///
/// 핵심 트릭: `web/index.html`이 이미 `<base href="/">`(루트 절대경로)를
/// 사용하므로, `build/web/tools/tool-chatgpt/index.html`처럼 깊은 경로에
/// 복사해 두어도 `flutter_bootstrap.js`/`main.dart.js`/`manifest.json` 등의
/// 상대 경로 참조가 여전히 `/flutter_bootstrap.js`처럼 루트 기준으로
/// 풀린다. 즉 스크립트/링크 태그는 건드릴 필요가 없고, `<head>`의 메타
/// 정보만 라우트별로 교체하면 된다. Flutter 앱은 로드된 뒤 go_router가
/// 정상적으로 해당 경로를 클라이언트 사이드에서 다시 렌더링한다.
///
/// `/search`, `/favorites`는 개인화된 상태에 의존하는 페이지라 `noindex`로
/// 표시한다.
void main() {
  const baseUrl = 'https://sotongware-ai-story.web.app';
  final buildWebDir = Directory('build/web');
  if (!buildWebDir.existsSync()) {
    stderr.writeln(
      'build/web 디렉터리를 찾을 수 없습니다. 먼저 `flutter build web`을 실행해주세요.',
    );
    exit(1);
  }

  final templateFile = File('${buildWebDir.path}/index.html');
  if (!templateFile.existsSync()) {
    stderr.writeln('build/web/index.html을 찾을 수 없습니다.');
    exit(1);
  }
  final template = templateFile.readAsStringSync();

  final dataDir = Directory('assets/data');
  List<Map<String, dynamic>> readList(String file) {
    final f = File('${dataDir.path}/$file');
    if (!f.existsSync()) return [];
    final decoded = json.decode(f.readAsStringSync());
    if (decoded is! List) return [];
    return decoded.cast<Map<String, dynamic>>();
  }

  final timeline = readList('timeline.json');
  final eras = readList('eras.json');
  final concepts = readList('concepts.json');
  final tools = readList('ai_tools.json');
  final useCases = readList('use_cases.json');
  final workflows = readList('workflows.json');

  const noIndexPaths = {'/search', '/favorites'};

  var generatedCount = 0;

  void writePage(
    String path, {
    required String title,
    required String description,
    required List<_Breadcrumb> breadcrumb,
  }) {
    final noIndex = noIndexPaths.contains(path);
    final html = _buildHtml(
      template: template,
      canonicalUrl: '$baseUrl$path',
      title: title,
      description: description,
      noIndex: noIndex,
      breadcrumb: breadcrumb,
      baseUrl: baseUrl,
    );

    final outDir = path == '/'
        ? buildWebDir
        : Directory('${buildWebDir.path}$path');
    outDir.createSync(recursive: true);
    File('${outDir.path}/index.html').writeAsStringSync(html);
    generatedCount++;
  }

  String truncate(String text, [int maxLength = 140]) {
    final normalized = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.length <= maxLength) return normalized;
    return '${normalized.substring(0, maxLength)}...';
  }

  const defaultDescription =
      'AI의 역사와 변천, 핵심 개념, 활용 도구, 산업·농업 적용, 실전 워크플로와 미래 전망을 '
      '체계적으로 제공하는 소통웨어 공개 AI 지식 플랫폼입니다.';
  const suffix = ' | 소통AI스토리';
  final home = _Breadcrumb('홈', '/');

  // --- 최상위 메뉴 경로 ---
  final topLevelPages = <String, ({String title, String description})>{
    '/': (title: '소통AI스토리 | AI 역사·도구·활용·미래 지식 플랫폼', description: defaultDescription),
    '/timeline': (title: 'AI 역사 연대표$suffix', description: '1950년부터 현재까지 AI 역사의 주요 사건을 시간순으로 살펴봅니다.'),
    '/eras': (title: '시대별 AI 변천사$suffix', description: 'AI 발전을 여러 시대로 구분해 각 시기의 특징과 전환점을 설명합니다.'),
    '/concepts': (title: 'AI 핵심 개념$suffix', description: '머신러닝, 딥러닝, LLM 등 AI의 핵심 개념을 쉽게 풀어 설명합니다.'),
    '/tools': (title: 'AI 툴 탐색$suffix', description: '다양한 AI 도구를 카테고리와 조건별로 찾아봅니다.'),
    '/tool-compare': (title: 'AI 툴 비교$suffix', description: '최대 3개의 AI 도구를 나란히 비교해 봅니다.'),
    '/use-cases': (title: '분야별 AI 활용$suffix', description: '업종·직무별로 AI를 실제로 활용하는 사례를 소개합니다.'),
    '/popular-ai': (title: '인기·주목 AI$suffix', description: '현재 가장 널리 쓰이고 주목받는 AI 도구를 모았습니다.'),
    '/hidden-gems': (title: '숨은 보석 AI$suffix', description: '잘 알려지지 않았지만 유용한 AI 도구를 소개합니다.'),
    '/workflows': (title: '실전 AI 워크플로$suffix', description: '실제 업무에 AI를 단계별로 적용하는 워크플로를 안내합니다.'),
    '/korea-ai': (title: '대한민국과 AI$suffix', description: '한국의 AI 정책과 국내 기업의 AI 서비스를 다룹니다.'),
    '/industry-ai': (title: '산업·농업 AI$suffix', description: '제조·농업 등 다양한 산업 분야의 AI 활용 현황을 소개합니다.'),
    '/developer': (title: 'AI 개발자 공간$suffix', description: 'API, 프롬프트 엔지니어링, RAG 등 개발자를 위한 정보를 제공합니다.'),
    '/safety': (title: '안전·윤리·저작권$suffix', description: 'AI 사용 시 유의해야 할 안전, 윤리, 저작권 이슈를 다룹니다.'),
    '/future': (title: 'AI 미래 전망$suffix', description: '앞으로의 AI 발전 방향과 준비할 점을 전망합니다.'),
    '/glossary': (title: 'AI 용어사전$suffix', description: 'AI 관련 용어를 한글·영문으로 찾아볼 수 있습니다.'),
    '/sources': (title: '출처·검증센터$suffix', description: '콘텐츠에 사용된 출처와 검증 상태를 확인합니다.'),
    '/about': (title: '소통웨어 소개$suffix', description: '이 서비스를 만든 소통웨어를 소개합니다.'),
    '/search': (title: '통합 검색$suffix', description: '연대표, 시대, 핵심 개념, AI 툴, 활용사례, 워크플로, 용어사전, 출처를 한 번에 검색합니다.'),
    '/favorites': (title: '즐겨찾기$suffix', description: '즐겨찾기에 담은 콘텐츠를 모아봅니다.'),
  };

  for (final entry in topLevelPages.entries) {
    writePage(
      entry.key,
      title: entry.value.title,
      description: entry.value.description,
      breadcrumb: entry.key == '/'
          ? [home]
          : [home, _Breadcrumb(entry.value.title.replaceAll(suffix, ''), entry.key)],
    );
  }

  // --- 상세 페이지 ---
  final toolsCrumb = _Breadcrumb('AI 툴 탐색', '/tools');
  for (final t in tools) {
    final id = (t['id'] ?? '').toString();
    if (id.isEmpty) continue;
    final name = (t['name'] ?? '').toString();
    writePage(
      '/tools/$id',
      title: '$name$suffix',
      description: truncate((t['description'] ?? '').toString().isEmpty
          ? defaultDescription
          : (t['description'] as String)),
      breadcrumb: [home, toolsCrumb, _Breadcrumb(name, '/tools/$id')],
    );
  }

  final timelineCrumb = _Breadcrumb('AI 역사 연대표', '/timeline');
  for (final t in timeline) {
    final id = (t['id'] ?? '').toString();
    if (id.isEmpty) continue;
    final title = (t['title'] ?? '').toString();
    writePage(
      '/timeline/$id',
      title: '$title$suffix',
      description: truncate((t['summary'] ?? '').toString().isEmpty
          ? defaultDescription
          : (t['summary'] as String)),
      breadcrumb: [home, timelineCrumb, _Breadcrumb(title, '/timeline/$id')],
    );
  }

  final erasCrumb = _Breadcrumb('시대별 AI 변천사', '/eras');
  for (final e in eras) {
    final id = (e['id'] ?? '').toString();
    if (id.isEmpty) continue;
    final title = (e['title'] ?? '').toString();
    writePage(
      '/eras/$id',
      title: '$title$suffix',
      description: truncate((e['keyQuestion'] ?? '').toString().isEmpty
          ? defaultDescription
          : (e['keyQuestion'] as String)),
      breadcrumb: [home, erasCrumb, _Breadcrumb(title, '/eras/$id')],
    );
  }

  final conceptsCrumb = _Breadcrumb('AI 핵심 개념', '/concepts');
  for (final c in concepts) {
    final id = (c['id'] ?? '').toString();
    if (id.isEmpty) continue;
    final name = (c['name'] ?? '').toString();
    writePage(
      '/concepts/$id',
      title: '$name$suffix',
      description: truncate((c['oneLiner'] ?? '').toString().isEmpty
          ? defaultDescription
          : (c['oneLiner'] as String)),
      breadcrumb: [home, conceptsCrumb, _Breadcrumb(name, '/concepts/$id')],
    );
  }

  final useCasesCrumb = _Breadcrumb('분야별 AI 활용', '/use-cases');
  for (final u in useCases) {
    final id = (u['id'] ?? '').toString();
    if (id.isEmpty) continue;
    final title = (u['title'] ?? '').toString();
    writePage(
      '/use-cases/$id',
      title: '$title$suffix',
      description: truncate(defaultDescription),
      breadcrumb: [home, useCasesCrumb, _Breadcrumb(title, '/use-cases/$id')],
    );
  }

  final workflowsCrumb = _Breadcrumb('실전 AI 워크플로', '/workflows');
  for (final w in workflows) {
    final id = (w['id'] ?? '').toString();
    if (id.isEmpty) continue;
    final title = (w['title'] ?? '').toString();
    writePage(
      '/workflows/$id',
      title: '$title$suffix',
      description: truncate((w['summary'] ?? '').toString().isEmpty
          ? defaultDescription
          : (w['summary'] as String)),
      breadcrumb: [home, workflowsCrumb, _Breadcrumb(title, '/workflows/$id')],
    );
  }

  print('SEO 정적 페이지 생성 완료: $generatedCount개');
}

class _Breadcrumb {
  _Breadcrumb(this.name, this.path);

  final String name;
  final String path;
}

String _buildHtml({
  required String template,
  required String canonicalUrl,
  required String title,
  required String description,
  required bool noIndex,
  required List<_Breadcrumb> breadcrumb,
  required String baseUrl,
}) {
  var html = template;

  html = html.replaceFirst(
    RegExp(r'<title>[^<]*</title>'),
    '<title>${_escape(title)}</title>',
  );
  html = html.replaceFirst(
    RegExp(r'<meta name="description" content="[^"]*">'),
    '<meta name="description" content="${_escape(description)}">',
  );
  html = html.replaceFirst(
    RegExp(r'<meta name="robots" content="[^"]*">'),
    '<meta name="robots" content="${noIndex ? 'noindex, nofollow' : 'index, follow'}">',
  );
  html = html.replaceFirst(
    RegExp(r'<link rel="canonical" href="[^"]*">'),
    '<link rel="canonical" href="$canonicalUrl">',
  );
  html = html.replaceFirst(
    RegExp(r'<meta property="og:title" content="[^"]*">'),
    '<meta property="og:title" content="${_escape(title)}">',
  );
  html = html.replaceFirst(
    RegExp(r'<meta property="og:description" content="[^"]*">'),
    '<meta property="og:description" content="${_escape(description)}">',
  );
  html = html.replaceFirst(
    RegExp(r'<meta property="og:url" content="[^"]*">'),
    '<meta property="og:url" content="$canonicalUrl">',
  );
  html = html.replaceFirst(
    RegExp(r'<meta name="twitter:title" content="[^"]*">'),
    '<meta name="twitter:title" content="${_escape(title)}">',
  );
  html = html.replaceFirst(
    RegExp(r'<meta name="twitter:description" content="[^"]*">'),
    '<meta name="twitter:description" content="${_escape(description)}">',
  );

  final breadcrumbJsonLd = json.encode({
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    'itemListElement': [
      for (var i = 0; i < breadcrumb.length; i++)
        {
          '@type': 'ListItem',
          'position': i + 1,
          'name': breadcrumb[i].name,
          'item': '$baseUrl${breadcrumb[i].path}',
        },
    ],
  });
  html = html.replaceFirst(
    '</head>',
    '  <script type="application/ld+json">$breadcrumbJsonLd</script>\n</head>',
  );

  return html;
}

String _escape(String value) {
  return value
      .replaceAll('&', '&amp;')
      .replaceAll('"', '&quot;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}
