import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter/services.dart' show rootBundle;

import '../constants/route_paths.dart';
import '../models/ai_tool.dart';
import '../models/concept.dart';
import '../models/content_status.dart';
import '../models/era.dart';
import '../models/future_trend.dart';
import '../models/glossary_entry.dart';
import '../models/page_section.dart';
import '../models/search_result.dart';
import '../models/site_updates.dart';
import '../models/source.dart';
import '../models/timeline_entry.dart';
import '../models/use_case.dart';
import '../models/verification_stats.dart';
import '../models/workflow.dart';
import '../utils/json_helpers.dart';
import '../utils/search_utils.dart';

/// 홈 화면 통계 카드에 사용할 콘텐츠 개수 요약.
///
/// 지연 로딩되는 콘텐츠(타임라인/도구/워크플로/용어사전)는 아직 로드되지
/// 않았다면 `content_index.json`에 미리 저장된 개수를 대신 사용하고, 로드가
/// 끝난 뒤에는 실제 목록 길이로 자동 전환된다. 덕분에 홈 화면은 지연 로딩
/// 완료를 기다리지 않고도 통계를 즉시 보여줄 수 있다.
class ContentStats {
  const ContentStats({
    required this.timelineCount,
    required this.eraCount,
    required this.conceptCount,
    required this.toolCount,
    required this.workflowCount,
    required this.useCaseCount,
    required this.glossaryCount,
    required this.sourceCount,
  });

  final int timelineCount;
  final int eraCount;
  final int conceptCount;
  final int toolCount;
  final int workflowCount;
  final int useCaseCount;
  final int glossaryCount;
  final int sourceCount;
}

/// 지연 로딩되는 콘텐츠 묶음 하나를 표현하는 내부 헬퍼.
///
/// 여러 화면에서 동시에 [ensure]를 호출해도 실제 로딩은 한 번만 수행되도록
/// [Completer]로 진행 중인 요청을 공유하고, 실패 시에는 다음 [ensure] 호출에서
/// 재시도할 수 있도록 상태를 초기화한다.
class _LazyBundle<T> {
  _LazyBundle(this.name, this.loader);

  final String name;
  final Future<T> Function() loader;

  T? _value;
  Completer<T>? _completer;
  Object? error;

  bool get isLoaded => _value != null;
  T? get valueOrNull => _value;

  Future<T> ensure() {
    final current = _value;
    if (current != null) return Future.value(current);
    final existing = _completer;
    if (existing != null) return existing.future;

    final completer = Completer<T>();
    _completer = completer;
    final stopwatch = Stopwatch()..start();

    loader()
        .then((value) {
          _value = value;
          error = null;
          _completer = null;
          if (kDebugMode) {
            debugPrint('Loaded $name in ${stopwatch.elapsedMilliseconds}ms');
          }
          completer.complete(value);
        })
        .catchError((Object e, StackTrace st) {
          error = e;
          _completer = null;
          completer.completeError(e, st);
        });

    return completer.future;
  }
}

/// 앱 전역에서 사용하는 콘텐츠 저장소.
///
/// ## 로딩 전략
///
/// 앱을 최대한 빨리 표시하기 위해 두 단계로 데이터를 로드한다.
///
/// 1. [loadBootstrap] — 앱 시작 시 1회만 호출한다. `site_updates.json`,
///    가벼운 `content_index.json`(홈 통계용 개수 캐시), 그리고 여러 페이지에서
///    공통으로 참조되는 중간 크기 데이터(sources/eras/concepts/use_cases/
///    future_trends/korea_ai/industry_ai/developer/safety)를 즉시 로드한다.
/// 2. 목록이 큰 콘텐츠(timeline/ai_tools/workflows/glossary)는
///    `ensureXxx()` 메서드를 통해 해당 화면에 처음 진입할 때 지연 로딩되며,
///    이후에는 메모리에 캐시되어 재요청 시 즉시 반환된다.
///
/// [loadAll]은 기존처럼 모든 데이터를 한 번에 로드하는 편의 메서드로,
/// 테스트나 `tool/validate_content_data.dart`류 스크립트에서 사용한다.
class ContentRepository {
  ContentRepository();

  bool _bootstrapped = false;
  bool get isLoaded => _bootstrapped;

  // --- 부트스트랩 단계에서 즉시 로드되는 데이터 ---
  List<Source> _sources = const [];
  List<Era> _eras = const [];
  List<Concept> _concepts = const [];
  List<UseCase> _useCases = const [];
  List<FutureTrend> _futureTrends = const [];
  SiteUpdates _siteUpdates = SiteUpdates.empty();
  List<PageSection> _koreaAiSections = const [];
  List<PageSection> _industrySections = const [];
  List<PageSection> _agricultureSections = const [];
  List<PageSection> _developerTopics = const [];
  List<PageSection> _safetyTopics = const [];

  // `content_index.json`에서 읽어온, 지연 로딩 데이터의 대략적인 개수(홈 통계용).
  int _indexTimelineCount = 0;
  int _indexToolCount = 0;
  int _indexWorkflowCount = 0;
  int _indexGlossaryCount = 0;

  // --- 지연 로딩 데이터 묶음 ---
  late final _LazyBundle<List<TimelineEntry>> _timelineBundle = _LazyBundle(
    'timeline',
    () => _loadJsonList('timeline.json').then(
      (rows) =>
          rows.map(TimelineEntry.fromJson).toList()..sort((a, b) {
            final byYear = a.year.compareTo(b.year);
            if (byYear != 0) return byYear;
            return (a.month ?? 0).compareTo(b.month ?? 0);
          }),
    ),
  );

  late final _LazyBundle<List<AiTool>> _toolsBundle = _LazyBundle(
    'tools',
    () => _loadJsonList(
      'ai_tools.json',
    ).then((rows) => rows.map(AiTool.fromJson).toList()),
  );

  late final _LazyBundle<List<Workflow>> _workflowsBundle = _LazyBundle(
    'workflows',
    () => _loadJsonList(
      'workflows.json',
    ).then((rows) => rows.map(Workflow.fromJson).toList()),
  );

  late final _LazyBundle<List<GlossaryEntry>> _glossaryBundle = _LazyBundle(
    'glossary',
    () => _loadJsonList(
      'glossary.json',
    ).then((rows) => rows.map(GlossaryEntry.fromJson).toList()),
  );

  List<Source> get sources => _sources;
  List<TimelineEntry> get timeline => _timelineBundle.valueOrNull ?? const [];
  List<Era> get eras => _eras;
  List<Concept> get concepts => _concepts;
  List<AiTool> get tools => _toolsBundle.valueOrNull ?? const [];
  List<Workflow> get workflows => _workflowsBundle.valueOrNull ?? const [];
  List<UseCase> get useCases => _useCases;
  List<GlossaryEntry> get glossary => _glossaryBundle.valueOrNull ?? const [];
  List<FutureTrend> get futureTrends => _futureTrends;
  SiteUpdates get siteUpdates => _siteUpdates;
  List<PageSection> get koreaAiSections => _koreaAiSections;
  List<PageSection> get industrySections => _industrySections;
  List<PageSection> get agricultureSections => _agricultureSections;
  List<PageSection> get developerTopics => _developerTopics;
  List<PageSection> get safetyTopics => _safetyTopics;

  /// 지연 로딩 데이터의 로드 완료 여부(콘텐츠 영역에서 로딩 스켈레톤 표시용).
  bool get isTimelineLoaded => _timelineBundle.isLoaded;
  bool get isToolsLoaded => _toolsBundle.isLoaded;
  bool get isWorkflowsLoaded => _workflowsBundle.isLoaded;
  bool get isGlossaryLoaded => _glossaryBundle.isLoaded;

  /// 지연 로딩 데이터의 마지막 로드 실패 원인(재시도용 에러 상태 표시).
  Object? get timelineError => _timelineBundle.error;
  Object? get toolsError => _toolsBundle.error;
  Object? get workflowsError => _workflowsBundle.error;
  Object? get glossaryError => _glossaryBundle.error;

  /// 타임라인 데이터를 처음 필요할 때 로드하고, 이후에는 캐시를 재사용한다.
  Future<void> ensureTimeline() => _timelineBundle.ensure();

  /// AI 도구 데이터를 처음 필요할 때 로드하고, 이후에는 캐시를 재사용한다.
  Future<void> ensureTools() => _toolsBundle.ensure();

  /// 워크플로 데이터를 처음 필요할 때 로드하고, 이후에는 캐시를 재사용한다.
  Future<void> ensureWorkflows() => _workflowsBundle.ensure();

  /// 용어사전 데이터를 처음 필요할 때 로드하고, 이후에는 캐시를 재사용한다.
  Future<void> ensureGlossary() => _glossaryBundle.ensure();

  /// 출처 목록은 여러 페이지에서 인용 배지로 널리 참조되므로 부트스트랩 시
  /// 항상 로드되지만, 명시적으로 다시 기다리고 싶은 화면(출처·검증센터)을 위해
  /// 동일한 이름의 메서드를 제공한다. 이미 로드되어 있으면 즉시 반환한다.
  Future<void> ensureSources() async {
    if (_sources.isNotEmpty || _bootstrapped) return;
    _sources = (await _loadJsonList('sources.json'))
        .map((e) => Source.fromJson(e))
        .toList();
  }

  /// 인기 AI 도구(isPopular == true) 목록. 사용 전 [ensureTools]가 필요하다.
  List<AiTool> get popularTools => tools.where((t) => t.isPopular).toList();

  /// 숨은 보석 AI 도구(isHiddenGem == true) 목록. 사용 전 [ensureTools]가 필요하다.
  List<AiTool> get hiddenGemTools =>
      tools.where((t) => t.isHiddenGem).toList();

  /// 앱 시작 시 1회 호출하는 경량 부트스트랩.
  ///
  /// `site_updates.json`, `content_index.json`(홈 통계 캐시)과 여러 페이지에서
  /// 공통으로 쓰이는 중간 크기 데이터만 즉시 로드한다. 목록이 큰
  /// timeline/ai_tools/workflows/glossary는 여기서 로드하지 않고, 각 화면이
  /// [ensureTimeline] 등을 호출할 때 비로소 로드된다.
  Future<void> loadBootstrap() async {
    final stopwatch = Stopwatch()..start();
    final results = await Future.wait([
      _loadJsonMap('site_updates.json'),
      _loadJsonMapSafe('content_index.json'),
      _loadJsonList('sources.json'),
      _loadJsonList('eras.json'),
      _loadJsonList('concepts.json'),
      _loadJsonList('use_cases.json'),
      _loadJsonList('future_trends.json'),
      _loadJsonMap('korea_ai.json'),
      _loadJsonMap('industry_ai.json'),
      _loadJsonMap('developer.json'),
      _loadJsonMap('safety.json'),
    ]);

    _siteUpdates = SiteUpdates.fromJson(results[0] as Map<String, dynamic>);

    final index = results[1] as Map<String, dynamic>;
    _indexTimelineCount = asInt(index['timelineCount']);
    _indexToolCount = asInt(index['toolCount']);
    _indexWorkflowCount = asInt(index['workflowCount']);
    _indexGlossaryCount = asInt(index['glossaryCount']);

    _sources = (results[2] as List).map((e) => Source.fromJson(e)).toList();
    _eras = (results[3] as List).map((e) => Era.fromJson(e)).toList();
    _concepts = (results[4] as List).map((e) => Concept.fromJson(e)).toList();
    _useCases = (results[5] as List).map((e) => UseCase.fromJson(e)).toList();
    _futureTrends = (results[6] as List)
        .map((e) => FutureTrend.fromJson(e))
        .toList();

    final koreaMap = results[7] as Map<String, dynamic>;
    _koreaAiSections = ((koreaMap['sections'] as List?) ?? [])
        .map((e) => PageSection.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    final industryMap = results[8] as Map<String, dynamic>;
    _industrySections = ((industryMap['industrySections'] as List?) ?? [])
        .map((e) => PageSection.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    _agricultureSections = ((industryMap['agricultureSections'] as List?) ?? [])
        .map((e) => PageSection.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    final developerMap = results[9] as Map<String, dynamic>;
    _developerTopics = ((developerMap['topics'] as List?) ?? [])
        .map((e) => PageSection.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    final safetyMap = results[10] as Map<String, dynamic>;
    _safetyTopics = ((safetyMap['topics'] as List?) ?? [])
        .map((e) => PageSection.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    _bootstrapped = true;
    if (kDebugMode) {
      debugPrint('Loaded bootstrap in ${stopwatch.elapsedMilliseconds}ms');
    }
  }

  /// 모든 데이터(부트스트랩 + 지연 로딩 묶음 전체)를 한 번에 로드하는 편의
  /// 메서드. 테스트나 `tool/validate_content_data.dart` 같은 검증 스크립트,
  /// 또는 오프라인 사용을 위한 사전 로딩 등에 사용한다.
  Future<void> loadAll() async {
    await loadBootstrap();
    await Future.wait([
      ensureTimeline(),
      ensureTools(),
      ensureWorkflows(),
      ensureGlossary(),
    ]);
  }

  Future<List<Map<String, dynamic>>> _loadJsonList(String fileName) async {
    final raw = await rootBundle.loadString('assets/data/$fileName');
    final decoded = json.decode(raw);
    if (decoded is! List) {
      throw FormatException('$fileName의 최상위 구조가 배열이 아닙니다.');
    }
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> _loadJsonMap(String fileName) async {
    final raw = await rootBundle.loadString('assets/data/$fileName');
    final decoded = json.decode(raw);
    if (decoded is! Map) {
      throw FormatException('$fileName의 최상위 구조가 객체가 아닙니다.');
    }
    return Map<String, dynamic>.from(decoded);
  }

  /// [_loadJsonMap]과 동일하지만 파일이 없거나 손상된 경우 예외를 던지지
  /// 않고 빈 맵을 반환한다. `content_index.json`은 홈 통계를 더 빨리 보여주기
  /// 위한 보조 캐시일 뿐이므로, 이 파일이 없어도 앱 부트스트랩 자체가
  /// 실패해서는 안 된다(개수는 지연 로딩 완료 후 실제 값으로 대체된다).
  Future<Map<String, dynamic>> _loadJsonMapSafe(String fileName) async {
    try {
      return await _loadJsonMap(fileName);
    } catch (_) {
      return const {};
    }
  }

  /// 홈 화면 통계 카드용 개수 요약.
  ///
  /// 지연 로딩된 데이터는 실제 길이를, 아직 로드되지 않은 데이터는
  /// `content_index.json`에서 읽은 대략적인 개수를 사용해 즉시 반환한다.
  ContentStats get stats => ContentStats(
    timelineCount: _timelineBundle.valueOrNull?.length ?? _indexTimelineCount,
    eraCount: _eras.length,
    conceptCount: _concepts.length,
    toolCount: _toolsBundle.valueOrNull?.length ?? _indexToolCount,
    workflowCount: _workflowsBundle.valueOrNull?.length ?? _indexWorkflowCount,
    useCaseCount: _useCases.length,
    glossaryCount: _glossaryBundle.valueOrNull?.length ?? _indexGlossaryCount,
    sourceCount: _sources.length,
  );

  Source? sourceById(String id) {
    for (final s in _sources) {
      if (s.id == id) return s;
    }
    return null;
  }

  TimelineEntry? timelineById(String id) =>
      _findById(timeline, id, (e) => e.id);
  Era? eraById(String id) => _findById(_eras, id, (e) => e.id);
  Concept? conceptById(String id) => _findById(_concepts, id, (e) => e.id);
  AiTool? toolById(String id) => _findById(tools, id, (e) => e.id);
  Workflow? workflowById(String id) => _findById(workflows, id, (e) => e.id);
  UseCase? useCaseById(String id) => _findById(_useCases, id, (e) => e.id);

  T? _findById<T>(List<T> list, String id, String Function(T) idOf) {
    for (final item in list) {
      if (idOf(item) == id) return item;
    }
    return null;
  }

  /// 최근 검증일(verifiedAt) 기준으로 정렬된 최신 검증 콘텐츠 목록(홈 화면용).
  ///
  /// 호출 전 [ensureTimeline]으로 타임라인이 로드되어 있어야 한다.
  List<TimelineEntry> get recentlyVerifiedTimeline {
    final sorted = [...timeline]
      ..sort((a, b) => b.verifiedAt.compareTo(a.verifiedAt));
    return sorted.take(6).toList();
  }

  /// 사이트 전체 콘텐츠의 검증 현황을 스캔해 [VerificationStats]를 계산한다.
  ///
  /// 지연 로딩되는 묶음(timeline/tools/workflows/glossary)이 아직 로드되지
  /// 않았다면 먼저 로드를 완료한 뒤 집계하므로, 이 메서드가 끝나면 항상
  /// 전체 콘텐츠를 기준으로 한 정확한 통계를 얻을 수 있다.
  Future<VerificationStats> computeVerificationStats() async {
    await Future.wait([
      ensureTimeline(),
      ensureTools(),
      ensureWorkflows(),
      ensureGlossary(),
    ]);

    final statuses = <ContentStatus>[];
    var missingSources = 0;

    void scan(List<ContentStatus> allStatuses, List<List<String>> allRefs) {
      statuses.addAll(allStatuses);
      missingSources += allRefs.where((refs) => refs.isEmpty).length;
    }

    scan(
      timeline.map((e) => e.status).toList(),
      timeline.map((e) => e.sourceIds).toList(),
    );
    scan(
      _eras.map((e) => e.status).toList(),
      _eras.map((e) => e.sourceIds).toList(),
    );
    scan(
      _concepts.map((e) => e.status).toList(),
      _concepts.map((e) => e.sourceIds).toList(),
    );
    scan(
      tools.map((e) => e.status).toList(),
      tools.map((e) => e.sourceIds).toList(),
    );
    scan(
      workflows.map((e) => e.status).toList(),
      workflows.map((e) => e.sourceIds).toList(),
    );
    scan(
      _useCases.map((e) => e.status).toList(),
      _useCases.map((e) => e.sourceIds).toList(),
    );
    scan(
      glossary.map((e) => e.status).toList(),
      glossary.map((e) => e.sourceIds).toList(),
    );
    scan(
      _futureTrends.map((e) => e.status).toList(),
      _futureTrends.map((e) => e.sourceIds).toList(),
    );

    int count(ContentStatus status) =>
        statuses.where((s) => s == status).length;

    return VerificationStats(
      total: statuses.length,
      verified: count(ContentStatus.verified),
      partiallyVerified: count(ContentStatus.partiallyVerified),
      verificationRequired: count(ContentStatus.verificationRequired),
      expired: count(ContentStatus.expired),
      forecast: count(ContentStatus.forecast),
      active: count(ContentStatus.active),
      discontinued: count(ContentStatus.inactive),
      unknown: count(ContentStatus.unknown),
      missingSources: missingSources,
    );
  }

  /// 여러 콘텐츠 타입을 아우르는 통합 검색.
  ///
  /// 지연 로딩되는 타임라인/도구/워크플로/용어사전을 검색 대상에 포함하기
  /// 위해 먼저 해당 묶음들을 로드한다(이미 로드되어 있다면 즉시 반환).
  Future<List<SearchResult>> search(String query) async {
    final q = normalizeSearchQuery(query);
    if (q.isEmpty) return const [];

    await Future.wait([
      ensureTimeline(),
      ensureTools(),
      ensureWorkflows(),
      ensureGlossary(),
    ]);

    final useChosung = isChosungOnlyQuery(q);

    bool matches(Iterable<String> fields) {
      for (final field in fields) {
        if (field.isEmpty) continue;
        if (useChosung) {
          if (matchesChosung(field, q.replaceAll(' ', ''))) return true;
        } else if (normalizeSearchQuery(field).contains(q)) {
          return true;
        }
      }
      return false;
    }

    final results = <SearchResult>[];

    for (final t in timeline) {
      if (matches([
        t.title,
        t.summary,
        t.details,
        t.background,
        ...t.tags,
        ...t.relatedPeople,
        ...t.relatedOrganizations,
      ])) {
        results.add(
          SearchResult(
            type: SearchResultType.timeline,
            id: t.id,
            title: t.title,
            snippet: t.summary,
            routePath: RoutePaths.timelineDetailOf(t.id),
            status: t.status,
            verifiedAt: t.verifiedAt,
          ),
        );
      }
    }
    for (final e in _eras) {
      if (matches([e.title, e.keyQuestion])) {
        results.add(
          SearchResult(
            type: SearchResultType.era,
            id: e.id,
            title: e.title,
            snippet: e.keyQuestion,
            routePath: RoutePaths.erasDetailOf(e.id),
            status: e.status,
            verifiedAt: e.verifiedAt,
          ),
        );
      }
    }
    for (final c in _concepts) {
      if (matches([c.name, c.oneLiner])) {
        results.add(
          SearchResult(
            type: SearchResultType.concept,
            id: c.id,
            title: c.name,
            snippet: c.oneLiner,
            routePath: RoutePaths.conceptsDetailOf(c.id),
            status: c.status,
            verifiedAt: c.verifiedAt,
          ),
        );
      }
    }
    for (final t in tools) {
      if (matches([
        t.name,
        t.company,
        t.description,
        aiToolCategoryLabel(t.category),
        ...t.keyFeatures,
        ...t.strengths,
        ...t.recommendedUseCases,
        ...t.targetUsers,
        ...t.badges,
      ])) {
        results.add(
          SearchResult(
            type: SearchResultType.tool,
            id: t.id,
            title: t.name,
            snippet: t.description,
            routePath: RoutePaths.toolsDetailOf(t.id),
            status: t.status,
            verifiedAt: t.lastVerified,
          ),
        );
      }
    }
    for (final u in _useCases) {
      if (matches([u.title, ...u.expectedBenefits])) {
        results.add(
          SearchResult(
            type: SearchResultType.useCase,
            id: u.id,
            title: u.title,
            snippet: u.expectedBenefits.join(', '),
            routePath: RoutePaths.useCasesDetailOf(u.id),
            status: u.status,
            verifiedAt: u.verifiedAt,
          ),
        );
      }
    }
    for (final w in workflows) {
      if (matches([w.title, w.summary])) {
        results.add(
          SearchResult(
            type: SearchResultType.workflow,
            id: w.id,
            title: w.title,
            snippet: w.summary,
            routePath: RoutePaths.workflowsDetailOf(w.id),
            status: w.status,
            verifiedAt: w.verifiedAt,
          ),
        );
      }
    }
    for (final g in glossary) {
      if (matches([g.koreanTerm, g.englishTerm, g.shortDescription])) {
        results.add(
          SearchResult(
            type: SearchResultType.glossary,
            id: g.id,
            title: '${g.koreanTerm} (${g.englishTerm})',
            snippet: g.shortDescription,
            routePath: RoutePaths.glossary,
            status: g.status,
            verifiedAt: g.verifiedAt,
          ),
        );
      }
    }
    for (final f in _futureTrends) {
      if (matches([f.title, f.possibility])) {
        results.add(
          SearchResult(
            type: SearchResultType.futureTrend,
            id: f.id,
            title: f.title,
            snippet: f.possibility,
            routePath: RoutePaths.future,
            status: f.status,
            verifiedAt: f.verifiedAt,
          ),
        );
      }
    }
    for (final s in _sources) {
      if (matches([s.title, s.publisher, s.note])) {
        results.add(
          SearchResult(
            type: SearchResultType.source,
            id: s.id,
            title: s.title,
            snippet: '${s.publisher} · ${s.publishedDate}',
            routePath: RoutePaths.sources,
            verifiedAt: s.accessedDate,
          ),
        );
      }
    }

    return results;
  }
}
