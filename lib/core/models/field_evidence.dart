import '../utils/json_helpers.dart';

/// 개별 필드(요금제, 한국어 지원 등)에 대한 검증 상태.
enum EvidenceStatus {
  /// 출처로 명확히 검증됨.
  verified,

  /// 일부만 검증되었거나 보조 출처로만 뒷받침됨.
  partiallyVerified,

  /// 재검증이 필요함(시간이 지났거나 출처가 불충분함).
  verificationRequired,

  /// 확인할 수 없음(출처가 없거나 비공개 정보).
  unavailable,

  /// 이 항목에는 해당 필드가 적용되지 않음.
  notApplicable;

  /// JSON 문자열 값을 [EvidenceStatus]로 변환한다.
  static EvidenceStatus fromJson(String? value) {
    switch (value) {
      case 'verified':
        return EvidenceStatus.verified;
      case 'partiallyVerified':
        return EvidenceStatus.partiallyVerified;
      case 'verificationRequired':
        return EvidenceStatus.verificationRequired;
      case 'unavailable':
        return EvidenceStatus.unavailable;
      case 'notApplicable':
        return EvidenceStatus.notApplicable;
      default:
        return EvidenceStatus.verificationRequired;
    }
  }

  /// JSON에 저장할 문자열 값.
  String get jsonValue => name;

  /// UI에 표시할 한국어 라벨.
  String get label {
    switch (this) {
      case EvidenceStatus.verified:
        return '검증 완료';
      case EvidenceStatus.partiallyVerified:
        return '부분 검증';
      case EvidenceStatus.verificationRequired:
        return '재검증 필요';
      case EvidenceStatus.unavailable:
        return '확인 불가';
      case EvidenceStatus.notApplicable:
        return '해당 없음';
    }
  }
}

/// 특정 필드(예: `pricingKind`, `koreanSupportLevel`, `apiAvailability`)에 대한
/// 검증 근거 한 건.
///
/// 하나의 도구/콘텐츠 항목은 필드별로 서로 다른 검증 상태와 만료일을 가질 수
/// 있으므로, 전체 상태를 하나의 값으로 뭉뚱그리지 않고 필드 단위로 기록한다.
class FieldEvidence {
  const FieldEvidence({
    required this.field,
    required this.status,
    required this.sourceIds,
    this.checkedAt,
    this.expiresAt,
    this.note = '',
  });

  /// 이 근거가 설명하는 필드 이름(예: `pricingKind`).
  final String field;

  /// 검증 상태.
  final EvidenceStatus status;

  /// 근거로 사용된 출처 ID 목록(`sources.json` 참조).
  final List<String> sourceIds;

  /// 마지막으로 확인한 날짜(`yyyy-MM-dd`).
  final DateTime? checkedAt;

  /// 이 검증이 유효한 만료일(`yyyy-MM-dd`). 지나면 재검증이 필요하다.
  final DateTime? expiresAt;

  /// 검증과 관련한 추가 설명.
  final String note;

  /// [expiresAt]이 오늘보다 과거인지 여부.
  bool get isExpired {
    final expires = expiresAt;
    if (expires == null) return false;
    final today = DateTime.now();
    final expiresDateOnly = DateTime(expires.year, expires.month, expires.day);
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    return expiresDateOnly.isBefore(todayDateOnly);
  }

  /// 만료 여부를 반영한 실제 상태. 만료됐다면 항상 [EvidenceStatus.verificationRequired].
  EvidenceStatus get effectiveStatus =>
      isExpired ? EvidenceStatus.verificationRequired : status;

  factory FieldEvidence.fromJson(Map<String, dynamic> json) {
    return FieldEvidence(
      field: asString(json['field']),
      status: EvidenceStatus.fromJson(asStringOrNull(json['status'])),
      sourceIds: asStringList(json['sourceIds']),
      checkedAt: _parseDate(asStringOrNull(json['checkedAt'])),
      expiresAt: _parseDate(asStringOrNull(json['expiresAt'])),
      note: asString(json['note']),
    );
  }

  Map<String, dynamic> toJson() => {
    'field': field,
    'status': status.jsonValue,
    'sourceIds': sourceIds,
    if (checkedAt != null) 'checkedAt': _formatDate(checkedAt!),
    if (expiresAt != null) 'expiresAt': _formatDate(expiresAt!),
    if (note.isNotEmpty) 'note': note,
  };

  static DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  static String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

/// JSON 배열을 [FieldEvidence] 목록으로 안전하게 변환한다.
List<FieldEvidence> asFieldEvidenceList(Object? value) {
  if (value == null) return const [];
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((e) => FieldEvidence.fromJson(asMap(e)))
      .toList();
}
