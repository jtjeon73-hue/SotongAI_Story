import '../utils/json_helpers.dart';

/// `assets/data/sources.json`의 개별 출처 항목.
class Source {
  const Source({
    required this.id,
    required this.title,
    required this.publisher,
    required this.url,
    required this.publishedDate,
    required this.accessedDate,
    required this.sourceType,
    required this.language,
    required this.note,
  });

  final String id;
  final String title;
  final String publisher;
  final String url;
  final String publishedDate;
  final String accessedDate;
  final String sourceType;
  final String language;
  final String note;

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      id: asString(json['id']),
      title: asString(json['title']),
      publisher: asString(json['publisher']),
      url: asString(json['url']),
      publishedDate: asString(json['publishedDate']),
      accessedDate: asString(json['accessedDate']),
      sourceType: asString(json['sourceType']),
      language: asString(json['language']),
      note: asString(json['note']),
    );
  }
}
