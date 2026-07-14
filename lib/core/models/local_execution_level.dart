/// AI 도구의 로컬(오프라인) 실행 지원 수준을 나타내는 열거형.
enum LocalExecutionLevel {
  /// 공식적으로 로컬 실행을 지원.
  supported,

  /// 일부 기능/모델 크기에서만 로컬 실행이 가능.
  partiallySupported,

  /// 공식 지원은 아니지만 커뮤니티가 만든 방법으로 로컬 실행이 가능.
  communityBased,

  /// 로컬 실행을 지원하지 않음(클라우드 전용).
  notSupported,

  /// 아직 확인되지 않음.
  unknown;

  /// JSON 문자열 값을 [LocalExecutionLevel]로 변환한다. 인식할 수 없으면 [unknown].
  static LocalExecutionLevel fromJson(String? value) {
    switch (value) {
      case 'supported':
        return LocalExecutionLevel.supported;
      case 'partiallySupported':
        return LocalExecutionLevel.partiallySupported;
      case 'communityBased':
        return LocalExecutionLevel.communityBased;
      case 'notSupported':
        return LocalExecutionLevel.notSupported;
      default:
        return LocalExecutionLevel.unknown;
    }
  }

  /// JSON에 저장할 문자열 값.
  String get jsonValue => name;

  /// UI에 표시할 한국어 라벨.
  String get label {
    switch (this) {
      case LocalExecutionLevel.supported:
        return '로컬 실행 지원';
      case LocalExecutionLevel.partiallySupported:
        return '로컬 실행 부분 지원';
      case LocalExecutionLevel.communityBased:
        return '커뮤니티 기반 로컬 실행';
      case LocalExecutionLevel.notSupported:
        return '로컬 실행 미지원';
      case LocalExecutionLevel.unknown:
        return '로컬 실행 확인 필요';
    }
  }

  /// 필터 등에서 "로컬 실행 가능"으로 간주할 수 있는지 여부(unknown은 제외).
  bool get canRunLocally =>
      this == LocalExecutionLevel.supported ||
      this == LocalExecutionLevel.partiallySupported ||
      this == LocalExecutionLevel.communityBased;
}
