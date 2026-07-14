/// AI 도구의 요금제 종류를 나타내는 열거형.
///
/// 기존 `pricingType`(free/freemium/paid 등 자유 문자열)을 대체하는
/// 정형화된 값으로, 필터링과 정렬에 안정적으로 사용할 수 있다.
enum PricingKind {
  /// 완전 무료.
  free,

  /// 무료 요금제와 유료 요금제를 함께 제공.
  freemium,

  /// 유료 전용.
  paid,

  /// 엔터프라이즈/기업 계약 중심(별도 견적).
  enterprise,

  /// 오픈소스로 공개되어 직접 실행·수정 가능.
  openSource,

  /// 아직 확인되지 않음.
  unknown;

  /// JSON 문자열 값을 [PricingKind]로 변환한다. 인식할 수 없으면 [unknown].
  static PricingKind fromJson(String? value) {
    switch (value) {
      case 'free':
        return PricingKind.free;
      case 'freemium':
        return PricingKind.freemium;
      case 'paid':
        return PricingKind.paid;
      case 'enterprise':
        return PricingKind.enterprise;
      case 'openSource':
        return PricingKind.openSource;
      default:
        return PricingKind.unknown;
    }
  }

  /// 기존 `pricingType` 자유 문자열 값을 [PricingKind]로 매핑한다.
  static PricingKind fromLegacyPricingType(String? value) {
    switch (value) {
      case 'free':
        return PricingKind.free;
      case 'freemium':
        return PricingKind.freemium;
      case 'paid':
        return PricingKind.paid;
      case 'enterprise':
        return PricingKind.enterprise;
      case 'open_source':
      case 'openSource':
        return PricingKind.openSource;
      default:
        return PricingKind.unknown;
    }
  }

  /// JSON에 저장할 문자열 값.
  String get jsonValue => name;

  /// UI에 표시할 한국어 라벨.
  String get label {
    switch (this) {
      case PricingKind.free:
        return '무료';
      case PricingKind.freemium:
        return '무료+유료 혼합';
      case PricingKind.paid:
        return '유료';
      case PricingKind.enterprise:
        return '기업 전용(견적)';
      case PricingKind.openSource:
        return '오픈소스';
      case PricingKind.unknown:
        return '요금제 확인 필요';
    }
  }

  /// 무료로 이용 가능한 방법이 있다고 볼 수 있는 종류인지 여부.
  bool get hasFreeAccess =>
      this == PricingKind.free ||
      this == PricingKind.freemium ||
      this == PricingKind.openSource;
}
