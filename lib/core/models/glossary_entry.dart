import '../utils/json_helpers.dart';
import 'content_status.dart';

/// `assets/data/glossary.json`의 개별 용어 항목.
class GlossaryEntry {
  const GlossaryEntry({
    required this.id,
    required this.koreanTerm,
    required this.englishTerm,
    required this.shortDescription,
    required this.technicalDescription,
    required this.example,
    required this.relatedTerms,
    required this.category,
    required this.sourceIds,
    required this.verifiedAt,
    required this.status,
  });

  final String id;
  final String koreanTerm;
  final String englishTerm;
  final String shortDescription;
  final String technicalDescription;
  final String example;
  final List<String> relatedTerms;
  final String category;
  final List<String> sourceIds;
  final String verifiedAt;
  final ContentStatus status;

  factory GlossaryEntry.fromJson(Map<String, dynamic> json) {
    return GlossaryEntry(
      id: asString(json['id']),
      koreanTerm: asString(json['koreanTerm']),
      englishTerm: asString(json['englishTerm']),
      shortDescription: asString(json['shortDescription']),
      technicalDescription: asString(json['technicalDescription']),
      example: asString(json['example']),
      relatedTerms: asStringList(json['relatedTerms']),
      category: asString(json['category']),
      sourceIds: asStringList(json['sourceIds']),
      verifiedAt: asString(json['verifiedAt']),
      status: ContentStatus.fromJson(asStringOrNull(json['status'])),
    );
  }
}
