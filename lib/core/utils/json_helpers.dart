/// JSON 파싱 시 null-safety를 지키기 위한 공용 헬퍼 함수 모음.
///
/// 원본 JSON 데이터의 필드가 비어있거나 예상 타입과 다를 경우에도 앱이
/// 크래시 없이 합리적인 기본값으로 대체할 수 있도록 한다.
library;

/// [value]를 문자열로 안전하게 변환한다. null이면 [fallback]을 반환한다.
String asString(Object? value, [String fallback = '']) {
  if (value == null) return fallback;
  if (value is String) return value;
  return value.toString();
}

/// [value]를 nullable 문자열로 변환한다. 빈 문자열은 null로 취급하지 않는다.
String? asStringOrNull(Object? value) {
  if (value == null) return null;
  if (value is String) return value;
  return value.toString();
}

/// [value]를 정수로 안전하게 변환한다. null이거나 파싱에 실패하면 [fallback].
int asInt(Object? value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

/// [value]를 nullable 정수로 변환한다.
int? asIntOrNull(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return int.tryParse(value);
  return null;
}

/// [value]를 불리언으로 안전하게 변환한다.
bool asBool(Object? value, [bool fallback = false]) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  return fallback;
}

/// [value]를 `List<String>`으로 안전하게 변환한다. null이면 빈 리스트.
List<String> asStringList(Object? value) {
  if (value == null) return const [];
  if (value is List) {
    return value.map((e) => asString(e)).where((e) => e.isNotEmpty).toList();
  }
  return const [];
}

/// [value]를 3상(tri-state) 불리언으로 변환한다.
///
/// 일반 [asBool]과 달리 값이 없거나(`null`) 인식할 수 없는 타입인 경우
/// `false`로 단정하지 않고 `null`("확인 필요/미확인")을 반환한다.
/// `koreanSupport`처럼 "미제공"과 "확인되지 않음"을 구분해야 하는 필드에 사용한다.
bool? asTriStateBool(Object? value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true') return true;
    if (normalized == 'false') return false;
    if (normalized.isEmpty ||
        normalized == 'unknown' ||
        normalized == 'unverified' ||
        normalized == 'unconfirmed') {
      return null;
    }
    return null;
  }
  return null;
}

/// [value]를 열거형 문자열로 변환한다.
///
/// [allowedValues]에 포함된 값만 유효한 것으로 인정하며, 값이 없거나
/// 허용되지 않는 값이면 `null`("미확인")을 반환한다. 즉, 알 수 없는 값을
/// 임의의 기본값으로 단정하지 않는다.
String? asStringEnum(Object? value, Set<String> allowedValues) {
  final str = asStringOrNull(value);
  if (str == null) return null;
  return allowedValues.contains(str) ? str : null;
}

/// [value]를 `Map<String, dynamic>`으로 안전하게 변환한다. null이면 빈 맵.
Map<String, dynamic> asMap(Object? value) {
  if (value is Map) {
    return value.map((key, val) => MapEntry(asString(key), val));
  }
  return const {};
}

/// [value]를 `List<Map<String, dynamic>>`으로 안전하게 변환한다.
List<Map<String, dynamic>> asMapList(Object? value) {
  if (value == null) return const [];
  if (value is List) {
    return value.whereType<Map>().map(asMap).toList();
  }
  return const [];
}
