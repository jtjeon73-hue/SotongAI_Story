/// 사이트 전체 콘텐츠의 검증 현황을 집계한 통계.
///
/// 기존에는 `site_updates.json`의 `pendingVerificationCount`를 사람이 손으로
/// 갱신했지만, 이제는 [ContentRepository.computeVerificationStats]가 로드된
/// 콘텐츠의 `status`/`sourceIds` 값을 직접 스캔해 자동으로 계산한다.
class VerificationStats {
  const VerificationStats({
    required this.total,
    required this.verified,
    required this.partiallyVerified,
    required this.verificationRequired,
    required this.expired,
    required this.forecast,
    required this.active,
    required this.discontinued,
    required this.unknown,
    required this.missingSources,
  });

  /// 집계에 포함된 전체 콘텐츠 항목 수(모든 콘텐츠 타입 합계).
  final int total;

  /// 출처 기반으로 검증이 완료된 항목 수.
  final int verified;

  /// 일부만 검증된 항목 수.
  final int partiallyVerified;

  /// 추가 검증이 필요한 항목 수.
  final int verificationRequired;

  /// 검증 유효기간이 지나 재검증이 필요한 항목 수.
  final int expired;

  /// 확정된 사실이 아닌 전망·분석성 항목 수.
  final int forecast;

  /// 현재 서비스 중/활성 상태인 항목 수.
  final int active;

  /// 서비스가 종료되었거나 중단된 항목 수.
  final int discontinued;

  /// 상태 값이 없거나 인식할 수 없는 항목 수.
  final int unknown;

  /// 출처(`sourceIds`)가 하나도 연결되지 않은 항목 수.
  final int missingSources;

  /// 검증 완료로 볼 수 있는 항목의 비율(검증 완료 + 부분 검증, 0~1).
  double get verifiedRatio {
    if (total == 0) return 0;
    return (verified + partiallyVerified) / total;
  }

  /// 사람의 주의가 필요한 항목 수(검증 필요 + 만료 + 미확인).
  int get needsAttention => verificationRequired + expired + unknown;

  factory VerificationStats.empty() => const VerificationStats(
    total: 0,
    verified: 0,
    partiallyVerified: 0,
    verificationRequired: 0,
    expired: 0,
    forecast: 0,
    active: 0,
    discontinued: 0,
    unknown: 0,
    missingSources: 0,
  );
}
