import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/ai_tool.dart';
import '../models/concept.dart';
import '../models/era.dart';
import '../models/future_trend.dart';
import '../models/glossary_entry.dart';
import '../models/page_section.dart';
import '../models/search_result.dart';
import '../models/site_updates.dart';
import '../models/source.dart';
import '../models/timeline_entry.dart';
import '../models/use_case.dart';
import '../models/workflow.dart';
import '../constants/route_paths.dart';

/// 홈 화면 통계 카드에 사용할 콘텐츠 개수 요약.
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

/// 앱 전역에서 사용하는 콘텐츠 저장소.
///
/// `assets/data/*.json`을 앱 시작 시 한 번 로드해 메모리에 캐시하고,
/// 각 화면에서는 getter를 통해 즉시 접근할 수 있게 한다. 로드 실패 시
/// [loadAll]이 던지는 예외를 UI 계층에서 잡아 에러 상태를 표시해야 한다.
class ContentRepository {
  ContentRepository();

  bool _loaded = false;
  bool get isLoaded => _loaded;

  List<Source> _sources = const [];
  List<TimelineEntry> _timeline = const [];
  List<Era> _eras = const [];
  List<Concept> _concepts = const [];
  List<AiTool> _tools = const [];
  List<Workflow> _workflows = const [];
  List<UseCase> _useCases = const [];
  List<GlossaryEntry> _glossary = const [];
  List<FutureTrend> _futureTrends = const [];
  SiteUpdates _siteUpdates = SiteUpdates.empty();
  List<PageSection> _koreaAiSections = const [];
  List<PageSection> _industrySections = const [];
  List<PageSection> _agricultureSections = const [];
  List<PageSection> _developerTopics = const [];
  List<PageSection> _safetyTopics = const [];

  List<Source> get sources => _sources;
  List<TimelineEntry> get timeline => _timeline;
  List<Era> get eras => _eras;
  List<Concept> get concepts => _concepts;
  List<AiTool> get tools => _tools;
  List<Workflow> get workflows => _workflows;
  List<UseCase> get useCases => _useCases;
  List<GlossaryEntry> get glossary => _glossary;
  List<FutureTrend> get futureTrends => _futureTrends;
  SiteUpdates get siteUpdates => _siteUpdates;
  List<PageSection> get koreaAiSections => _koreaAiSections;
  List<PageSection> get industrySections => _industrySections;
  List<PageSection> get agricultureSections => _agricultureSections;
  List<PageSection> get developerTopics => _developerTopics;
  List<PageSection> get safetyTopics => _safetyTopics;

  /// 인기 AI 도구(isPopular == true) 목록.
  List<AiTool> get popularTools => _tools.where((t) => t.isPopular).toList();

  /// 숨은 보석 AI 도구(isHiddenGem == true) 목록.
  List<AiTool> get hiddenGemTools =>
      _tools.where((t) => t.isHiddenGem).toList();

  /// 모든 데이터 파일을 assets에서 로드한다. 앱 시작 시 1회 호출한다.
  ///
  /// 개별 파일 파싱 중 예외가 발생하면 해당 파일은 빈 목록으로 남기지 않고
  /// 예외를 다시 던져, main()에서 로딩 화면이 에러 상태로 전환되도록 한다.
  Future<void> loadAll() async {
    final results = await Future.wait([
      _loadJsonList('sources.json'),
      _loadJsonList('timeline.json'),
      _loadJsonList('eras.json'),
      _loadJsonList('concepts.json'),
      _loadJsonList('ai_tools.json'),
      _loadJsonList('workflows.json'),
      _loadJsonList('use_cases.json'),
      _loadJsonList('glossary.json'),
      _loadJsonList('future_trends.json'),
      _loadJsonMap('site_updates.json'),
      _loadJsonMap('korea_ai.json'),
      _loadJsonMap('industry_ai.json'),
      _loadJsonMap('developer.json'),
      _loadJsonMap('safety.json'),
    ]);

    _sources = (results[0] as List).map((e) => Source.fromJson(e)).toList();
    _timeline =
        (results[1] as List).map((e) => TimelineEntry.fromJson(e)).toList()
          ..sort((a, b) {
            final byYear = a.year.compareTo(b.year);
            if (byYear != 0) return byYear;
            return (a.month ?? 0).compareTo(b.month ?? 0);
          });
    _eras = (results[2] as List).map((e) => Era.fromJson(e)).toList();
    _concepts = (results[3] as List).map((e) => Concept.fromJson(e)).toList();
    _tools = (results[4] as List).map((e) => AiTool.fromJson(e)).toList();
    _workflows = (results[5] as List).map((e) => Workflow.fromJson(e)).toList();
    _useCases = (results[6] as List).map((e) => UseCase.fromJson(e)).toList();
    _glossary = (results[7] as List)
        .map((e) => GlossaryEntry.fromJson(e))
        .toList();
    _futureTrends = (results[8] as List)
        .map((e) => FutureTrend.fromJson(e))
        .toList();

    final siteUpdatesMap = results[9] as Map<String, dynamic>;
    _siteUpdates = SiteUpdates.fromJson(siteUpdatesMap);

    final koreaMap = results[10] as Map<String, dynamic>;
    _koreaAiSections = ((koreaMap['sections'] as List?) ?? [])
        .map((e) => PageSection.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    final industryMap = results[11] as Map<String, dynamic>;
    _industrySections = ((industryMap['industrySections'] as List?) ?? [])
        .map((e) => PageSection.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    _agricultureSections = ((industryMap['agricultureSections'] as List?) ?? [])
        .map((e) => PageSection.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    final developerMap = results[12] as Map<String, dynamic>;
    _developerTopics = ((developerMap['topics'] as List?) ?? [])
        .map((e) => PageSection.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    final safetyMap = results[13] as Map<String, dynamic>;
    _safetyTopics = ((safetyMap['topics'] as List?) ?? [])
        .map((e) => PageSection.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    _loaded = true;
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

  ContentStats get stats => ContentStats(
    timelineCount: _timeline.length,
    eraCount: _eras.length,
    conceptCount: _concepts.length,
    toolCount: _tools.length,
    workflowCount: _workflows.length,
    useCaseCount: _useCases.length,
    glossaryCount: _glossary.length,
    sourceCount: _sources.length,
  );

  Source? sourceById(String id) {
    for (final s in _sources) {
      if (s.id == id) return s;
    }
    return null;
  }

  TimelineEntry? timelineById(String id) =>
      _findById(_timeline, id, (e) => e.id);
  Era? eraById(String id) => _findById(_eras, id, (e) => e.id);
  Concept? conceptById(String id) => _findById(_concepts, id, (e) => e.id);
  AiTool? toolById(String id) => _findById(_tools, id, (e) => e.id);
  Workflow? workflowById(String id) => _findById(_workflows, id, (e) => e.id);
  UseCase? useCaseById(String id) => _findById(_useCases, id, (e) => e.id);

  T? _findById<T>(List<T> list, String id, String Function(T) idOf) {
    for (final item in list) {
      if (idOf(item) == id) return item;
    }
    return null;
  }

  /// 최근 검증일(verifiedAt) 기준으로 정렬된 최신 검증 콘텐츠 목록(홈 화면용).
  List<TimelineEntry> get recentlyVerifiedTimeline {
    final sorted = [..._timeline]
      ..sort((a, b) => b.verifiedAt.compareTo(a.verifiedAt));
    return sorted.take(6).toList();
  }

  /// 여러 콘텐츠 타입을 아우르는 통합 검색.
  ///
  /// 제목/이름/요약 등 주요 텍스트 필드에 [query]가 포함되면 결과에 추가한다.
  List<SearchResult> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final results = <SearchResult>[];

    for (final t in _timeline) {
      if (t.title.toLowerCase().contains(q) ||
          t.summary.toLowerCase().contains(q)) {
        results.add(
          SearchResult(
            type: SearchResultType.timeline,
            id: t.id,
            title: t.title,
            snippet: t.summary,
            routePath: RoutePaths.timelineDetailOf(t.id),
          ),
        );
      }
    }
    for (final e in _eras) {
      if (e.title.toLowerCase().contains(q) ||
          e.keyQuestion.toLowerCase().contains(q)) {
        results.add(
          SearchResult(
            type: SearchResultType.era,
            id: e.id,
            title: e.title,
            snippet: e.keyQuestion,
            routePath: RoutePaths.erasDetailOf(e.id),
          ),
        );
      }
    }
    for (final c in _concepts) {
      if (c.name.toLowerCase().contains(q) ||
          c.oneLiner.toLowerCase().contains(q)) {
        results.add(
          SearchResult(
            type: SearchResultType.concept,
            id: c.id,
            title: c.name,
            snippet: c.oneLiner,
            routePath: RoutePaths.conceptsDetailOf(c.id),
          ),
        );
      }
    }
    for (final t in _tools) {
      if (t.name.toLowerCase().contains(q) ||
          t.description.toLowerCase().contains(q)) {
        results.add(
          SearchResult(
            type: SearchResultType.tool,
            id: t.id,
            title: t.name,
            snippet: t.description,
            routePath: RoutePaths.toolsDetailOf(t.id),
          ),
        );
      }
    }
    for (final u in _useCases) {
      if (u.title.toLowerCase().contains(q)) {
        results.add(
          SearchResult(
            type: SearchResultType.useCase,
            id: u.id,
            title: u.title,
            snippet: u.expectedBenefits.join(', '),
            routePath: RoutePaths.useCasesDetailOf(u.id),
          ),
        );
      }
    }
    for (final w in _workflows) {
      if (w.title.toLowerCase().contains(q) ||
          w.summary.toLowerCase().contains(q)) {
        results.add(
          SearchResult(
            type: SearchResultType.workflow,
            id: w.id,
            title: w.title,
            snippet: w.summary,
            routePath: RoutePaths.workflowsDetailOf(w.id),
          ),
        );
      }
    }
    for (final g in _glossary) {
      if (g.koreanTerm.toLowerCase().contains(q) ||
          g.englishTerm.toLowerCase().contains(q) ||
          g.shortDescription.toLowerCase().contains(q)) {
        results.add(
          SearchResult(
            type: SearchResultType.glossary,
            id: g.id,
            title: '${g.koreanTerm} (${g.englishTerm})',
            snippet: g.shortDescription,
            routePath: RoutePaths.glossary,
          ),
        );
      }
    }

    return results;
  }
}
