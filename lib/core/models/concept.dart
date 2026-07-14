import '../utils/json_helpers.dart';
import 'content_status.dart';

/// `assets/data/concepts.json`의 개별 AI 핵심 개념 항목.
class Concept {
  const Concept({
    required this.id,
    required this.name,
    required this.oneLiner,
    required this.analogy,
    required this.details,
    required this.useCases,
    required this.commonMisconceptions,
    required this.pros,
    required this.cons,
    required this.relatedConceptIds,
    required this.sourceIds,
    required this.verifiedAt,
    required this.status,
  });

  final String id;
  final String name;
  final String oneLiner;
  final String analogy;
  final String details;
  final List<String> useCases;
  final List<String> commonMisconceptions;
  final List<String> pros;
  final List<String> cons;
  final List<String> relatedConceptIds;
  final List<String> sourceIds;
  final String verifiedAt;
  final ContentStatus status;

  factory Concept.fromJson(Map<String, dynamic> json) {
    return Concept(
      id: asString(json['id']),
      name: asString(json['name']),
      oneLiner: asString(json['oneLiner']),
      analogy: asString(json['analogy']),
      details: asString(json['details']),
      useCases: asStringList(json['useCases']),
      commonMisconceptions: asStringList(json['commonMisconceptions']),
      pros: asStringList(json['pros']),
      cons: asStringList(json['cons']),
      relatedConceptIds: asStringList(json['relatedConceptIds']),
      sourceIds: asStringList(json['sourceIds']),
      verifiedAt: asString(json['verifiedAt']),
      status: ContentStatus.fromJson(asStringOrNull(json['status'])),
    );
  }
}
