import '../utils/json_helpers.dart';
import 'content_status.dart';

/// `assets/data/eras.json`의 개별 시대 구분 항목.
class Era {
  const Era({
    required this.id,
    required this.title,
    required this.period,
    required this.summary3Lines,
    required this.keyQuestion,
    required this.keyTechnologies,
    required this.keyPeople,
    required this.keyOrganizations,
    required this.expectations,
    required this.limitations,
    required this.transitionTrigger,
    required this.lastingImpact,
    required this.relatedTimelineIds,
    required this.sourceIds,
    required this.verifiedAt,
    required this.status,
  });

  final String id;
  final String title;
  final String period;
  final List<String> summary3Lines;
  final String keyQuestion;
  final List<String> keyTechnologies;
  final List<String> keyPeople;
  final List<String> keyOrganizations;
  final String expectations;
  final String limitations;
  final String transitionTrigger;
  final String lastingImpact;
  final List<String> relatedTimelineIds;
  final List<String> sourceIds;
  final String verifiedAt;
  final ContentStatus status;

  factory Era.fromJson(Map<String, dynamic> json) {
    return Era(
      id: asString(json['id']),
      title: asString(json['title']),
      period: asString(json['period']),
      summary3Lines: asStringList(json['summary3Lines']),
      keyQuestion: asString(json['keyQuestion']),
      keyTechnologies: asStringList(json['keyTechnologies']),
      keyPeople: asStringList(json['keyPeople']),
      keyOrganizations: asStringList(json['keyOrganizations']),
      expectations: asString(json['expectations']),
      limitations: asString(json['limitations']),
      transitionTrigger: asString(json['transitionTrigger']),
      lastingImpact: asString(json['lastingImpact']),
      relatedTimelineIds: asStringList(json['relatedTimelineIds']),
      sourceIds: asStringList(json['sourceIds']),
      verifiedAt: asString(json['verifiedAt']),
      status: ContentStatus.fromJson(asStringOrNull(json['status'])),
    );
  }
}
