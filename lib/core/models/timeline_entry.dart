import '../utils/json_helpers.dart';
import 'content_status.dart';

/// `assets/data/timeline.json`의 개별 연대표 사건.
class TimelineEntry {
  const TimelineEntry({
    required this.id,
    required this.title,
    required this.summary,
    required this.year,
    this.month,
    this.day,
    required this.dateText,
    required this.datePrecision,
    required this.era,
    required this.category,
    required this.importance,
    required this.details,
    required this.background,
    required this.whyItMatters,
    required this.currentConnection,
    required this.relatedPeople,
    required this.relatedOrganizations,
    required this.tags,
    required this.sourceIds,
    required this.verifiedAt,
    required this.status,
  });

  final String id;
  final String title;
  final String summary;
  final int year;
  final int? month;
  final int? day;
  final String dateText;
  final String datePrecision;
  final String era;
  final String category;
  final int importance;
  final String details;
  final String background;
  final String whyItMatters;
  final String currentConnection;
  final List<String> relatedPeople;
  final List<String> relatedOrganizations;
  final List<String> tags;
  final List<String> sourceIds;
  final String verifiedAt;
  final ContentStatus status;

  factory TimelineEntry.fromJson(Map<String, dynamic> json) {
    return TimelineEntry(
      id: asString(json['id']),
      title: asString(json['title']),
      summary: asString(json['summary']),
      year: asInt(json['year']),
      month: asIntOrNull(json['month']),
      day: asIntOrNull(json['day']),
      dateText: asString(json['dateText']),
      datePrecision: asString(json['datePrecision']),
      era: asString(json['era']),
      category: asString(json['category']),
      importance: asInt(json['importance'], 1),
      details: asString(json['details']),
      background: asString(json['background']),
      whyItMatters: asString(json['whyItMatters']),
      currentConnection: asString(json['currentConnection']),
      relatedPeople: asStringList(json['relatedPeople']),
      relatedOrganizations: asStringList(json['relatedOrganizations']),
      tags: asStringList(json['tags']),
      sourceIds: asStringList(json['sourceIds']),
      verifiedAt: asString(json['verifiedAt']),
      status: ContentStatus.fromJson(asStringOrNull(json['status'])),
    );
  }
}

/// 연대표 카테고리 코드를 한국어 라벨로 변환한다.
String timelineCategoryLabel(String category) {
  const map = {
    'research': '연구',
    'product_launch': '제품 출시',
    'policy': '정책',
    'competition': '대회·경쟁',
    'breakthrough': '기술적 도약',
    'infrastructure': '인프라',
    'international': '국제',
    'korea_policy': '한국 정책',
  };
  return map[category] ?? category;
}
