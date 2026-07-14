import '../utils/json_helpers.dart';

/// `assets/data/site_updates.json`의 사이트 갱신 메타데이터.
///
/// 검증 통계(검증 대기/완료 항목 수 등)는 더 이상 이 파일에 수동으로 기록하지
/// 않는다. 대신 [ContentRepository.computeVerificationStats]가 콘텐츠의
/// `status` 필드를 스캔해 자동으로 계산한다.
class SiteUpdates {
  const SiteUpdates({
    required this.siteLastUpdated,
    required this.contentLastVerified,
    required this.version,
    required this.notes,
  });

  final String siteLastUpdated;
  final String contentLastVerified;
  final String version;
  final List<String> notes;

  factory SiteUpdates.fromJson(Map<String, dynamic> json) {
    return SiteUpdates(
      siteLastUpdated: asString(json['siteLastUpdated']),
      contentLastVerified: asString(json['contentLastVerified']),
      version: asString(json['version']),
      notes: asStringList(json['notes']),
    );
  }

  factory SiteUpdates.empty() => const SiteUpdates(
    siteLastUpdated: '',
    contentLastVerified: '',
    version: '',
    notes: [],
  );
}
