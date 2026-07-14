import '../models/search_result.dart';
import '../constants/route_paths.dart';
import 'content_repository.dart';

/// [ContentRepository]에 출처 역참조(reverse lookup) 기능을 추가하는 확장.
///
/// 별도 파일의 확장(extension)으로 구현해, 지연 로딩 아키텍처가 자리한
/// `content_repository.dart` 본체를 직접 수정하지 않고도 "이 출처를 어떤
/// 콘텐츠가 인용하는지"를 조회할 수 있게 한다. 지연 로딩되는 콘텐츠
/// (타임라인/도구/워크플로/용어사전)는 먼저 `ensureXxx()`로 로드를 보장한 뒤
/// 스캔한다.
extension SourceUsageLookup on ContentRepository {
  /// [sourceId]를 `sourceIds`에 포함하는 모든 콘텐츠를 찾아 반환한다.
  ///
  /// 출처·검증센터에서 특정 출처를 펼쳤을 때 "이 출처를 사용하는 콘텐츠"
  /// 목록을 보여주는 데 사용한다. 호출 전에 관련 데이터셋이 로드되어
  /// 있어야 하므로, 필요하면 먼저 `ensureTimeline()`/`ensureTools()`/
  /// `ensureWorkflows()`/`ensureGlossary()`를 호출한다.
  Future<List<SearchResult>> contentUsingSource(String sourceId) async {
    final map = await allContentBySource();
    return map[sourceId] ?? const [];
  }

  /// 모든 출처에 대해 한 번의 스캔으로 "이 출처를 인용하는 콘텐츠" 맵을
  /// 만든다. 출처·검증센터처럼 여러 출처의 인용 개수를 한꺼번에 보여줘야 할
  /// 때 [contentUsingSource]를 출처마다 반복 호출하는 것보다 훨씬 효율적이다.
  Future<Map<String, List<SearchResult>>> allContentBySource() async {
    await Future.wait([
      ensureTimeline(),
      ensureTools(),
      ensureWorkflows(),
      ensureGlossary(),
    ]);

    final map = <String, List<SearchResult>>{};

    void addAll(Iterable<String> sourceIds, SearchResult Function() build) {
      if (sourceIds.isEmpty) return;
      final result = build();
      for (final id in sourceIds) {
        map.putIfAbsent(id, () => []).add(result);
      }
    }

    for (final t in timeline) {
      addAll(
        t.sourceIds,
        () => SearchResult(
          type: SearchResultType.timeline,
          id: t.id,
          title: t.title,
          snippet: t.summary,
          routePath: RoutePaths.timelineDetailOf(t.id),
        ),
      );
    }
    for (final e in eras) {
      addAll(
        e.sourceIds,
        () => SearchResult(
          type: SearchResultType.era,
          id: e.id,
          title: e.title,
          snippet: e.keyQuestion,
          routePath: RoutePaths.erasDetailOf(e.id),
        ),
      );
    }
    for (final c in concepts) {
      addAll(
        c.sourceIds,
        () => SearchResult(
          type: SearchResultType.concept,
          id: c.id,
          title: c.name,
          snippet: c.oneLiner,
          routePath: RoutePaths.conceptsDetailOf(c.id),
        ),
      );
    }
    for (final t in tools) {
      addAll(
        t.sourceIds,
        () => SearchResult(
          type: SearchResultType.tool,
          id: t.id,
          title: t.name,
          snippet: t.description,
          routePath: RoutePaths.toolsDetailOf(t.id),
        ),
      );
    }
    for (final w in workflows) {
      addAll(
        w.sourceIds,
        () => SearchResult(
          type: SearchResultType.workflow,
          id: w.id,
          title: w.title,
          snippet: w.summary,
          routePath: RoutePaths.workflowsDetailOf(w.id),
        ),
      );
    }
    for (final u in useCases) {
      addAll(
        u.sourceIds,
        () => SearchResult(
          type: SearchResultType.useCase,
          id: u.id,
          title: u.title,
          snippet: u.expectedBenefits.join(', '),
          routePath: RoutePaths.useCasesDetailOf(u.id),
        ),
      );
    }
    for (final g in glossary) {
      addAll(
        g.sourceIds,
        () => SearchResult(
          type: SearchResultType.glossary,
          id: g.id,
          title: '${g.koreanTerm} (${g.englishTerm})',
          snippet: g.shortDescription,
          routePath: RoutePaths.glossary,
        ),
      );
    }
    for (final f in futureTrends) {
      addAll(
        f.sourceIds,
        () => SearchResult(
          type: SearchResultType.futureTrend,
          id: f.id,
          title: f.title,
          snippet: f.possibility,
          routePath: RoutePaths.future,
        ),
      );
    }
    for (final section in [
      ...koreaAiSections,
      ...industrySections,
      ...agricultureSections,
      ...developerTopics,
      ...safetyTopics,
    ]) {
      addAll(
        section.sourceIds,
        () => SearchResult(
          type: SearchResultType.glossary,
          id: section.id,
          title: section.title,
          snippet: section.displayBody,
          routePath: RoutePaths.sources,
        ),
      );
    }

    return map;
  }
}
