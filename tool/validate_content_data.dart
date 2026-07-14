// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// `assets/data/*.json`의 데이터 정합성을 검사하는 독립 실행 스크립트.
///
/// 실행: `dart run tool/validate_content_data.dart`
///
/// 검사 항목:
/// - 각 파일 내 `id` 중복 여부
/// - `title`/`name` 등 제목 필드가 비어있는지
/// - `sourceIds`가 `sources.json`에 실제로 존재하는 id를 참조하는지
/// - 도구/워크플로를 참조하는 필드(`recommendedToolIds` 등)가 유효한지
/// - `verifiedAt` 등 날짜 필드가 `yyyy-MM-dd` 형식인지
///
/// 문제를 찾으면 종료 코드 1로 종료해 CI에서 실패로 감지할 수 있게 한다.
void main() async {
  final dataDir = Directory('assets/data');
  if (!dataDir.existsSync()) {
    stderr.writeln('assets/data 디렉터리를 찾을 수 없습니다. 프로젝트 루트에서 실행해주세요.');
    exit(1);
  }

  final errors = <String>[];
  final warnings = <String>[];

  Map<String, dynamic> readMap(String file) {
    final raw = File('${dataDir.path}/$file').readAsStringSync();
    return json.decode(raw) as Map<String, dynamic>;
  }

  List<Map<String, dynamic>> readList(String file) {
    final raw = File('${dataDir.path}/$file').readAsStringSync();
    final decoded = json.decode(raw);
    if (decoded is! List) {
      errors.add('$file: 최상위 구조가 배열이 아닙니다.');
      return [];
    }
    return decoded.cast<Map<String, dynamic>>();
  }

  final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  void checkDuplicateIds(String file, List<Map<String, dynamic>> items) {
    final seen = <String>{};
    for (final item in items) {
      final id = item['id']?.toString() ?? '';
      if (id.isEmpty) {
        errors.add(
          '$file: id가 비어있는 항목이 있습니다. ${item['title'] ?? item['name'] ?? ''}',
        );
        continue;
      }
      if (!seen.add(id)) {
        errors.add('$file: 중복된 id "$id"가 있습니다.');
      }
    }
  }

  void checkTitles(
    String file,
    List<Map<String, dynamic>> items,
    List<String> titleFields,
  ) {
    for (final item in items) {
      final id = item['id']?.toString() ?? '(id 없음)';
      final hasTitle = titleFields.any(
        (f) => (item[f]?.toString() ?? '').trim().isNotEmpty,
      );
      if (!hasTitle) {
        errors.add('$file: "$id" 항목에 ${titleFields.join('/')} 필드가 모두 비어있습니다.');
      }
    }
  }

  void checkDateField(
    String file,
    List<Map<String, dynamic>> items,
    String field,
  ) {
    for (final item in items) {
      final id = item['id']?.toString() ?? '(id 없음)';
      final value = item[field]?.toString() ?? '';
      if (value.isEmpty) {
        warnings.add('$file: "$id" 항목의 $field 필드가 비어있습니다.');
      } else if (!dateRegex.hasMatch(value)) {
        errors.add('$file: "$id" 항목의 $field 값 "$value"이 yyyy-MM-dd 형식이 아닙니다.');
      }
    }
  }

  void checkSourceRefs(
    String file,
    List<Map<String, dynamic>> items,
    Set<String> validSourceIds,
  ) {
    for (final item in items) {
      final id = item['id']?.toString() ?? '(id 없음)';
      final refs =
          (item['sourceIds'] as List?)?.map((e) => e.toString()) ?? const [];
      for (final ref in refs) {
        if (!validSourceIds.contains(ref)) {
          errors.add('$file: "$id" 항목이 존재하지 않는 sourceId "$ref"를 참조합니다.');
        }
      }
    }
  }

  void checkIdRefs(
    String file,
    List<Map<String, dynamic>> items,
    String field,
    Set<String> validIds,
    String targetLabel,
  ) {
    for (final item in items) {
      final id = item['id']?.toString() ?? '(id 없음)';
      final refs = (item[field] as List?)?.map((e) => e.toString()) ?? const [];
      for (final ref in refs) {
        if (!validIds.contains(ref)) {
          errors.add(
            '$file: "$id" 항목의 $field가 존재하지 않는 $targetLabel id "$ref"를 참조합니다.',
          );
        }
      }
    }
  }

  // --- sources.json ---
  final sources = readList('sources.json');
  checkDuplicateIds('sources.json', sources);
  checkTitles('sources.json', sources, ['title']);
  final sourceIds = sources.map((s) => s['id']?.toString() ?? '').toSet();

  // --- timeline.json ---
  final timeline = readList('timeline.json');
  checkDuplicateIds('timeline.json', timeline);
  checkTitles('timeline.json', timeline, ['title']);
  checkDateField('timeline.json', timeline, 'verifiedAt');
  checkSourceRefs('timeline.json', timeline, sourceIds);
  final timelineIds = timeline.map((t) => t['id']?.toString() ?? '').toSet();

  // --- eras.json ---
  final eras = readList('eras.json');
  checkDuplicateIds('eras.json', eras);
  checkTitles('eras.json', eras, ['title']);
  checkDateField('eras.json', eras, 'verifiedAt');
  checkSourceRefs('eras.json', eras, sourceIds);
  checkIdRefs('eras.json', eras, 'relatedTimelineIds', timelineIds, 'timeline');

  // --- concepts.json ---
  final concepts = readList('concepts.json');
  checkDuplicateIds('concepts.json', concepts);
  checkTitles('concepts.json', concepts, ['name']);
  checkDateField('concepts.json', concepts, 'verifiedAt');
  checkSourceRefs('concepts.json', concepts, sourceIds);
  final conceptIds = concepts.map((c) => c['id']?.toString() ?? '').toSet();
  checkIdRefs(
    'concepts.json',
    concepts,
    'relatedConceptIds',
    conceptIds,
    'concept',
  );

  // --- ai_tools.json ---
  final tools = readList('ai_tools.json');
  checkDuplicateIds('ai_tools.json', tools);
  checkTitles('ai_tools.json', tools, ['name']);
  checkDateField('ai_tools.json', tools, 'lastVerified');
  checkSourceRefs('ai_tools.json', tools, sourceIds);
  final toolIds = tools.map((t) => t['id']?.toString() ?? '').toSet();

  // --- workflows.json ---
  final workflows = readList('workflows.json');
  checkDuplicateIds('workflows.json', workflows);
  checkTitles('workflows.json', workflows, ['title']);
  checkDateField('workflows.json', workflows, 'verifiedAt');
  checkSourceRefs('workflows.json', workflows, sourceIds);
  checkIdRefs('workflows.json', workflows, 'recommendedTools', toolIds, 'tool');
  checkIdRefs('workflows.json', workflows, 'relatedToolIds', toolIds, 'tool');
  final workflowIds = workflows.map((w) => w['id']?.toString() ?? '').toSet();

  // --- use_cases.json ---
  final useCases = readList('use_cases.json');
  checkDuplicateIds('use_cases.json', useCases);
  checkTitles('use_cases.json', useCases, ['title']);
  checkDateField('use_cases.json', useCases, 'verifiedAt');
  checkSourceRefs('use_cases.json', useCases, sourceIds);
  checkIdRefs(
    'use_cases.json',
    useCases,
    'recommendedToolIds',
    toolIds,
    'tool',
  );
  checkIdRefs(
    'use_cases.json',
    useCases,
    'relatedWorkflowIds',
    workflowIds,
    'workflow',
  );

  // --- glossary.json ---
  final glossary = readList('glossary.json');
  checkDuplicateIds('glossary.json', glossary);
  checkTitles('glossary.json', glossary, ['koreanTerm', 'englishTerm']);
  checkDateField('glossary.json', glossary, 'verifiedAt');
  checkSourceRefs('glossary.json', glossary, sourceIds);

  // --- future_trends.json ---
  final futureTrends = readList('future_trends.json');
  checkDuplicateIds('future_trends.json', futureTrends);
  checkTitles('future_trends.json', futureTrends, ['title']);
  checkDateField('future_trends.json', futureTrends, 'verifiedAt');
  checkSourceRefs('future_trends.json', futureTrends, sourceIds);

  // --- site_updates.json ---
  try {
    final siteUpdates = readMap('site_updates.json');
    for (final field in ['siteLastUpdated', 'contentLastVerified']) {
      final value = siteUpdates[field]?.toString() ?? '';
      if (value.isNotEmpty && !dateRegex.hasMatch(value)) {
        errors.add(
          'site_updates.json: $field 값 "$value"이 yyyy-MM-dd 형식이 아닙니다.',
        );
      }
    }
  } catch (e) {
    errors.add('site_updates.json 파싱 실패: $e');
  }

  // --- korea_ai.json / industry_ai.json / developer.json / safety.json ---
  void checkSectionFile(String file, List<String> sectionKeys) {
    try {
      final map = readMap(file);
      for (final key in sectionKeys) {
        final sections =
            (map[key] as List?)?.cast<Map<String, dynamic>>() ?? [];
        checkDuplicateIds('$file[$key]', sections);
        checkTitles('$file[$key]', sections, ['title']);
        checkDateField('$file[$key]', sections, 'verifiedAt');
        checkSourceRefs('$file[$key]', sections, sourceIds);
      }
    } catch (e) {
      errors.add('$file 파싱 실패: $e');
    }
  }

  checkSectionFile('korea_ai.json', ['sections']);
  checkSectionFile('industry_ai.json', [
    'industrySections',
    'agricultureSections',
  ]);
  checkSectionFile('developer.json', ['topics']);
  checkSectionFile('safety.json', ['topics']);

  // --- content_index.json ---
  // 홈 화면이 지연 로딩 전에 즉시 통계를 보여주기 위해 사용하는 캐시 파일이다.
  // 실제 데이터셋과 개수가 어긋나면 홈 통계가 부정확해지므로 항상 동기화 여부를 검사한다.
  try {
    final index = readMap('content_index.json');
    void checkCount(String field, int actual) {
      final declared = index[field];
      if (declared is! int) {
        errors.add('content_index.json: "$field" 필드가 없거나 정수가 아닙니다.');
      } else if (declared != actual) {
        errors.add(
          'content_index.json: "$field" 값($declared)이 실제 개수($actual)와 다릅니다.',
        );
      }
    }

    checkCount('timelineCount', timeline.length);
    checkCount('eraCount', eras.length);
    checkCount('conceptCount', concepts.length);
    checkCount('toolCount', tools.length);
    checkCount('workflowCount', workflows.length);
    checkCount('useCaseCount', useCases.length);
    checkCount('glossaryCount', glossary.length);
    checkCount('futureTrendCount', futureTrends.length);
    checkCount('sourceCount', sources.length);

    final recentVerifiedDate = index['recentVerifiedDate']?.toString() ?? '';
    if (recentVerifiedDate.isEmpty) {
      warnings.add('content_index.json: recentVerifiedDate가 비어있습니다.');
    } else if (!dateRegex.hasMatch(recentVerifiedDate)) {
      errors.add(
        'content_index.json: recentVerifiedDate 값 "$recentVerifiedDate"이 '
        'yyyy-MM-dd 형식이 아닙니다.',
      );
    }
  } catch (e) {
    errors.add('content_index.json 파싱 실패: $e');
  }

  // --- 결과 출력 ---
  stdout.writeln('=== 소통AI스토리 데이터 검증 결과 ===');
  stdout.writeln(
    '검사 완료: sources(${sources.length}) timeline(${timeline.length}) eras(${eras.length}) '
    'concepts(${concepts.length}) tools(${tools.length}) workflows(${workflows.length}) '
    'use_cases(${useCases.length}) glossary(${glossary.length}) future_trends(${futureTrends.length})',
  );
  stdout.writeln('');

  if (warnings.isNotEmpty) {
    stdout.writeln('경고 ${warnings.length}건:');
    for (final w in warnings) {
      stdout.writeln('  - $w');
    }
    stdout.writeln('');
  }

  if (errors.isEmpty) {
    stdout.writeln('오류가 발견되지 않았습니다.');
    exit(0);
  } else {
    stdout.writeln('오류 ${errors.length}건 발견:');
    for (final e in errors) {
      stdout.writeln('  - $e');
    }
    exit(1);
  }
}
