/// 콘텐츠 검증/운영 상태를 나타내는 열거형.
///
/// 원본 JSON의 `status` 필드는 콘텐츠 종류에 따라 다른 값 집합을 사용하므로
/// (예: 타임라인은 verified/partiallyVerified, 도구는 active, 미래전망은
/// forecast) 하나의 열거형으로 통합해 UI에서 일관되게 배지를 표시한다.
enum ContentStatus {
  /// 출처를 통해 검증 완료된 콘텐츠.
  verified,

  /// 일부만 검증되었거나 보조 출처로 뒷받침되는 콘텐츠.
  partiallyVerified,

  /// 아직 검증이 완료되지 않아 추가 확인이 필요한 콘텐츠.
  verificationRequired,

  /// 확정된 사실이 아닌 전망·분석성 콘텐츠.
  forecast,

  /// 현재 서비스 중이거나 사용 가능한 도구/항목.
  active,

  /// 더 이상 서비스되지 않거나 사용이 중단된 항목.
  inactive,

  /// 검증 유효기간이 지나 재검증이 필요한 항목.
  expired,

  /// 값이 없거나 인식할 수 없는 상태.
  unknown;

  /// JSON 문자열 값을 [ContentStatus]로 변환한다.
  static ContentStatus fromJson(String? value) {
    switch (value) {
      case 'verified':
        return ContentStatus.verified;
      case 'partiallyVerified':
        return ContentStatus.partiallyVerified;
      case 'verificationRequired':
        return ContentStatus.verificationRequired;
      case 'forecast':
        return ContentStatus.forecast;
      case 'active':
        return ContentStatus.active;
      case 'inactive':
      case 'deprecated':
      case 'discontinued':
        return ContentStatus.inactive;
      case 'expired':
        return ContentStatus.expired;
      default:
        return ContentStatus.unknown;
    }
  }

  /// 배지 등에 사용할 한국어 라벨.
  String get label {
    switch (this) {
      case ContentStatus.verified:
        return '검증 완료';
      case ContentStatus.partiallyVerified:
        return '부분 검증';
      case ContentStatus.verificationRequired:
        return '검증 필요';
      case ContentStatus.forecast:
        return '전망·분석';
      case ContentStatus.active:
        return '서비스 중';
      case ContentStatus.inactive:
        return '서비스 종료';
      case ContentStatus.expired:
        return '검증 만료';
      case ContentStatus.unknown:
        return '상태 미확인';
    }
  }
}
