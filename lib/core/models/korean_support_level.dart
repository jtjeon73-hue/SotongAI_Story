/// AI 도구의 한국어 지원 수준을 나타내는 열거형.
///
/// 기존에는 `koreanSupport`(bool) 하나로만 표현했으나, 실제로는
/// "인터페이스만 한국어", "모델 응답만 한국어" 등 중간 단계가 존재하고,
/// 확인되지 않은 경우를 false와 구분해야 하므로 세분화한다.
enum KoreanSupportLevel {
  /// 인터페이스와 모델 응답 모두 한국어를 온전히 지원.
  full,

  /// 한국어를 지원하지만 기능·품질 면에서 일부 제한이 있음.
  partial,

  /// 화면(UI) 언어만 한국어로 제공되고, 모델 응답 품질은 별도 확인 필요.
  interfaceOnly,

  /// 모델 응답은 한국어가 가능하나 인터페이스는 한국어를 지원하지 않음.
  modelOnly,

  /// 한국어를 지원하지 않음.
  none,

  /// 아직 확인되지 않음. 절대 "미지원(false)"과 동일하게 표시하지 않는다.
  unknown;

  /// JSON 문자열 값을 [KoreanSupportLevel]로 변환한다. 인식할 수 없으면 [unknown].
  static KoreanSupportLevel fromJson(String? value) {
    switch (value) {
      case 'full':
        return KoreanSupportLevel.full;
      case 'partial':
        return KoreanSupportLevel.partial;
      case 'interfaceOnly':
        return KoreanSupportLevel.interfaceOnly;
      case 'modelOnly':
        return KoreanSupportLevel.modelOnly;
      case 'none':
        return KoreanSupportLevel.none;
      default:
        return KoreanSupportLevel.unknown;
    }
  }

  /// JSON에 저장할 문자열 값.
  String get jsonValue => name;

  /// UI에 표시할 한국어 라벨.
  String get label {
    switch (this) {
      case KoreanSupportLevel.full:
        return '한국어 완전 지원';
      case KoreanSupportLevel.partial:
        return '한국어 부분 지원';
      case KoreanSupportLevel.interfaceOnly:
        return '인터페이스만 한국어';
      case KoreanSupportLevel.modelOnly:
        return '모델 응답만 한국어';
      case KoreanSupportLevel.none:
        return '한국어 미지원';
      case KoreanSupportLevel.unknown:
        return '한국어 지원 확인 필요';
    }
  }

  /// 필터 등에서 "지원"으로 간주할 수 있는 수준인지 여부(unknown은 제외).
  bool get isSupportive =>
      this == KoreanSupportLevel.full ||
      this == KoreanSupportLevel.partial ||
      this == KoreanSupportLevel.interfaceOnly ||
      this == KoreanSupportLevel.modelOnly;
}
