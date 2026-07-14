import '../utils/json_helpers.dart';

/// `assets/data/site_updates.json`의 사이트 갱신 메타데이터.
class SiteUpdates {
  const SiteUpdates({
    required this.siteLastUpdated,
    required this.contentLastVerified,
    required this.version,
    required this.notes,
    required this.pendingVerificationCount,
  });

  final String siteLastUpdated;
  final String contentLastVerified;
  final String version;
  final List<String> notes;
  final int pendingVerificationCount;

  factory SiteUpdates.fromJson(Map<String, dynamic> json) {
    return SiteUpdates(
      siteLastUpdated: asString(json['siteLastUpdated']),
      contentLastVerified: asString(json['contentLastVerified']),
      version: asString(json['version']),
      notes: asStringList(json['notes']),
      pendingVerificationCount: asInt(json['pendingVerificationCount']),
    );
  }

  factory SiteUpdates.empty() => const SiteUpdates(
    siteLastUpdated: '',
    contentLastVerified: '',
    version: '',
    notes: [],
    pendingVerificationCount: 0,
  );
}
