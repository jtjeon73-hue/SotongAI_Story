import '../utils/json_helpers.dart';
import 'content_status.dart';

/// `assets/data/use_cases.json`의 개별 분야별 활용사례 항목.
class UseCase {
  const UseCase({
    required this.id,
    required this.title,
    required this.category,
    required this.problemsSolved,
    required this.recommendedToolIds,
    required this.usageSteps,
    required this.difficulty,
    required this.expectedBenefits,
    required this.costNotes,
    required this.privacyNotes,
    required this.humanCheckPoints,
    required this.gettingStarted,
    required this.relatedWorkflowIds,
    required this.sourceIds,
    required this.verifiedAt,
    required this.status,
  });

  final String id;
  final String title;
  final String category;
  final List<String> problemsSolved;
  final List<String> recommendedToolIds;
  final List<String> usageSteps;
  final String difficulty;
  final List<String> expectedBenefits;
  final String costNotes;
  final String privacyNotes;
  final List<String> humanCheckPoints;
  final String gettingStarted;
  final List<String> relatedWorkflowIds;
  final List<String> sourceIds;
  final String verifiedAt;
  final ContentStatus status;

  factory UseCase.fromJson(Map<String, dynamic> json) {
    return UseCase(
      id: asString(json['id']),
      title: asString(json['title']),
      category: asString(json['category']),
      problemsSolved: asStringList(json['problemsSolved']),
      recommendedToolIds: asStringList(json['recommendedToolIds']),
      usageSteps: asStringList(json['usageSteps']),
      difficulty: asString(json['difficulty']),
      expectedBenefits: asStringList(json['expectedBenefits']),
      costNotes: asString(json['costNotes']),
      privacyNotes: asString(json['privacyNotes']),
      humanCheckPoints: asStringList(json['humanCheckPoints']),
      gettingStarted: asString(json['gettingStarted']),
      relatedWorkflowIds: asStringList(json['relatedWorkflowIds']),
      sourceIds: asStringList(json['sourceIds']),
      verifiedAt: asString(json['verifiedAt']),
      status: ContentStatus.fromJson(asStringOrNull(json['status'])),
    );
  }
}

/// 분야(카테고리) 코드를 한국어 라벨로 변환한다.
String useCaseCategoryLabel(String category) {
  const map = {
    'retail': '소매·유통',
    'food_service': '외식업',
    'education': '교육',
    'healthcare': '의료',
    'legal': '법률',
    'real_estate': '부동산',
    'agriculture': '농업',
    'manufacturing': '제조',
    'logistics': '물류',
    'hr': '인사(HR)',
    'finance': '금융',
    'marketing': '마케팅',
    'customer_service': '고객서비스',
    'media': '미디어',
    'tourism': '관광',
    'construction': '건설',
    'freelance': '프리랜서',
    'nonprofit': '비영리',
    'public_sector': '공공부문',
    'insurance': '보험',
    'automotive': '자동차',
    'elderly_care': '노인돌봄',
    'startup': '스타트업',
  };
  return map[category] ?? category;
}
