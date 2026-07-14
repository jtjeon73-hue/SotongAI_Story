import '../utils/json_helpers.dart';
import 'content_status.dart';

/// `assets/data/future_trends.json`의 개별 미래 전망 항목.
class FutureTrend {
  const FutureTrend({
    required this.id,
    required this.title,
    required this.category,
    required this.type,
    required this.currentEvidence,
    required this.possibility,
    required this.expectedEffects,
    required this.risks,
    required this.individualPrep,
    required this.businessPrep,
    required this.publicPrep,
    required this.sourceIds,
    required this.verifiedAt,
    required this.status,
  });

  final String id;
  final String title;
  final String category;
  final String type;
  final String currentEvidence;
  final String possibility;
  final List<String> expectedEffects;
  final List<String> risks;
  final List<String> individualPrep;
  final List<String> businessPrep;
  final List<String> publicPrep;
  final List<String> sourceIds;
  final String verifiedAt;
  final ContentStatus status;

  factory FutureTrend.fromJson(Map<String, dynamic> json) {
    return FutureTrend(
      id: asString(json['id']),
      title: asString(json['title']),
      category: asString(json['category']),
      type: asString(json['type']),
      currentEvidence: asString(json['currentEvidence']),
      possibility: asString(json['possibility']),
      expectedEffects: asStringList(json['expectedEffects']),
      risks: asStringList(json['risks']),
      individualPrep: asStringList(json['individualPrep']),
      businessPrep: asStringList(json['businessPrep']),
      publicPrep: asStringList(json['publicPrep']),
      sourceIds: asStringList(json['sourceIds']),
      verifiedAt: asString(json['verifiedAt']),
      status: ContentStatus.fromJson(asStringOrNull(json['status'])),
    );
  }
}

/// 전망 유형(type) 코드를 한국어 배지 라벨로 변환한다.
String futureTrendTypeLabel(String type) {
  const map = {
    'confirmed_trend': '확인된 흐름',
    'analysis': '분석',
    'official_forecast': '공식 전망',
    'uncertain_scenario': '불확실한 시나리오',
  };
  return map[type] ?? type;
}
