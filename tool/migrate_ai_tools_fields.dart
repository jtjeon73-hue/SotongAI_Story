// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// `assets/data/ai_tools.json`에 신규 정밀화 필드를 "소프트 추가"하는
/// 1회성 마이그레이션 스크립트.
///
/// 실행: `dart run tool/migrate_ai_tools_fields.dart`
///
/// 이 스크립트는 기존 필드를 삭제하거나 값을 새로 지어내지 않는다.
/// 오직 다음 필드를 기존 값에서 유도해 "없을 때만" 추가한다:
/// - `koreanSupportLevel` (from `koreanSupport` + `koreanSupportNote`)
/// - `apiAvailability` (from `apiAvailable`)
/// - `pricingKind` (from `pricingType`)
/// - `localExecutionLevel` (from `localExecution`)
/// - `fieldEvidence` (pricing/koreanSupport/api 근거를 `sourceIds`가 있을 때만
///   최소 형태로 생성. 노트에 "확인"/"필요"가 있으면 verificationRequired,
///   아니면 partiallyVerified로 표시한다. 날짜는 지어내지 않고 비워둔다)
///
/// 이미 해당 필드가 있는 항목은 건드리지 않아 재실행해도 안전(idempotent)하다.
/// `lastVerified` 값은 절대 변경하지 않는다.
void main() {
  final file = File('assets/data/ai_tools.json');
  if (!file.existsSync()) {
    stderr.writeln('assets/data/ai_tools.json 파일을 찾을 수 없습니다.');
    exit(1);
  }

  final raw = file.readAsStringSync();
  final decoded = json.decode(raw);
  if (decoded is! List) {
    stderr.writeln('ai_tools.json의 최상위 구조가 배열이 아닙니다.');
    exit(1);
  }

  var migratedCount = 0;
  var evidenceAddedCount = 0;

  final migrated = decoded.map((raw) {
    final tool = Map<String, dynamic>.from(raw as Map);
    var changed = false;

    bool needsConfirmation(String note) =>
        note.contains('확인') || note.contains('필요');

    // koreanSupportLevel
    if (!tool.containsKey('koreanSupportLevel')) {
      final note = (tool['koreanSupportNote'] as String?) ?? '';
      final bool? support = tool['koreanSupport'] as bool?;
      String level;
      if (support == null) {
        level = 'unknown';
      } else {
        level = support ? 'full' : 'none';
      }
      if (needsConfirmation(note)) level = 'unknown';
      tool['koreanSupportLevel'] = level;
      changed = true;
    }

    // apiAvailability
    if (!tool.containsKey('apiAvailability')) {
      final bool? api = tool['apiAvailable'] as bool?;
      tool['apiAvailability'] = api == null
          ? 'unknown'
          : (api ? 'official' : 'none');
      changed = true;
    }

    // pricingKind
    if (!tool.containsKey('pricingKind')) {
      const map = {
        'free': 'free',
        'freemium': 'freemium',
        'paid': 'paid',
        'enterprise': 'enterprise',
        'open_source': 'openSource',
        'openSource': 'openSource',
      };
      final pricingType = (tool['pricingType'] as String?) ?? '';
      tool['pricingKind'] = map[pricingType] ?? 'unknown';
      changed = true;
    }

    // localExecutionLevel
    if (!tool.containsKey('localExecutionLevel')) {
      final bool? local = tool['localExecution'] as bool?;
      tool['localExecutionLevel'] = local == null
          ? 'unknown'
          : (local ? 'supported' : 'notSupported');
      changed = true;
    }

    // fieldEvidence: 출처가 있을 때만 최소 근거를 추가한다. 값을 지어내지 않는다.
    if (!tool.containsKey('fieldEvidence')) {
      final sourceIds = (tool['sourceIds'] as List?)?.cast<String>() ?? const [];
      if (sourceIds.isNotEmpty) {
        final evidence = <Map<String, dynamic>>[];

        void addEvidence(String field, String note) {
          final status = needsConfirmation(note)
              ? 'verificationRequired'
              : 'partiallyVerified';
          evidence.add({
            'field': field,
            'status': status,
            'sourceIds': sourceIds,
            if (note.isNotEmpty) 'note': note,
          });
        }

        addEvidence('pricingKind', (tool['pricingNote'] as String?) ?? '');
        addEvidence(
          'koreanSupportLevel',
          (tool['koreanSupportNote'] as String?) ?? '',
        );
        addEvidence('apiAvailability', '');

        if (evidence.isNotEmpty) {
          tool['fieldEvidence'] = evidence;
          evidenceAddedCount++;
        }
      }
      changed = true;
    }

    // 명시적 기본값(값을 지어내지 않고, 확인되지 않았음을 나타내는 중립 기본값만 추가).
    tool.putIfAbsent('limitsNote', () => '');
    tool.putIfAbsent('pricingVerifiedAt', () => '');

    if (changed) migratedCount++;
    return tool;
  }).toList();

  final encoder = JsonEncoder.withIndent('  ');
  final output = '${encoder.convert(migrated)}\n';
  file.writeAsStringSync(output);

  stdout.writeln('=== ai_tools.json 소프트 마이그레이션 완료 ===');
  stdout.writeln('전체 도구 수: ${migrated.length}');
  stdout.writeln('필드가 추가/보강된 도구 수: $migratedCount');
  stdout.writeln('fieldEvidence가 추가된 도구 수: $evidenceAddedCount');
  stdout.writeln('lastVerified 값은 변경하지 않았습니다.');
}
