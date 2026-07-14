/// AI 도구의 API 제공 형태를 나타내는 열거형.
enum ApiAvailability {
  /// 공식 API를 일반 사용자에게 공개 제공.
  official,

  /// 공식 API가 있으나 접근(신청, 대기열, 지역 등)이 제한적.
  limited,

  /// 엔터프라이즈/파트너 계약 등에서만 API를 제공.
  enterpriseOnly,

  /// 공식 API는 없으나 서드파티(비공식) 연동이 존재.
  thirdPartyOnly,

  /// API를 제공하지 않음.
  none,

  /// 아직 확인되지 않음.
  unknown;

  /// JSON 문자열 값을 [ApiAvailability]로 변환한다. 인식할 수 없으면 [unknown].
  static ApiAvailability fromJson(String? value) {
    switch (value) {
      case 'official':
        return ApiAvailability.official;
      case 'limited':
        return ApiAvailability.limited;
      case 'enterpriseOnly':
        return ApiAvailability.enterpriseOnly;
      case 'thirdPartyOnly':
        return ApiAvailability.thirdPartyOnly;
      case 'none':
        return ApiAvailability.none;
      default:
        return ApiAvailability.unknown;
    }
  }

  /// JSON에 저장할 문자열 값.
  String get jsonValue => name;

  /// UI에 표시할 한국어 라벨.
  String get label {
    switch (this) {
      case ApiAvailability.official:
        return '공식 API 제공';
      case ApiAvailability.limited:
        return 'API 제공(제한적)';
      case ApiAvailability.enterpriseOnly:
        return 'API 제공(엔터프라이즈 전용)';
      case ApiAvailability.thirdPartyOnly:
        return '서드파티 연동만 존재';
      case ApiAvailability.none:
        return 'API 미제공';
      case ApiAvailability.unknown:
        return 'API 제공 여부 확인 필요';
    }
  }

  /// 필터 등에서 "API 있음"으로 간주할 수 있는지 여부(unknown은 제외).
  bool get hasApi =>
      this == ApiAvailability.official ||
      this == ApiAvailability.limited ||
      this == ApiAvailability.enterpriseOnly;
}
