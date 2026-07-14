import '../utils/json_helpers.dart';
import 'content_status.dart';

/// `assets/data/ai_tools.json`의 개별 AI 도구 항목.
class AiTool {
  const AiTool({
    required this.id,
    required this.name,
    required this.company,
    required this.category,
    required this.description,
    required this.officialUrl,
    required this.launchDate,
    required this.platforms,
    required this.pricingType,
    required this.pricingNote,
    required this.koreanSupport,
    required this.koreanSupportNote,
    required this.targetUsers,
    required this.keyFeatures,
    required this.strengths,
    required this.limitations,
    required this.recommendedUseCases,
    required this.unsuitableUseCases,
    required this.apiAvailable,
    required this.localExecution,
    required this.fileUpload,
    required this.dataSafetyNote,
    required this.badges,
    required this.popularityEvidence,
    required this.sourceIds,
    required this.lastVerified,
    required this.status,
    required this.isPopular,
    required this.isHiddenGem,
  });

  final String id;
  final String name;
  final String company;
  final String category;
  final String description;
  final String officialUrl;
  final String launchDate;
  final List<String> platforms;
  final String pricingType;
  final String pricingNote;
  final bool koreanSupport;
  final String koreanSupportNote;
  final List<String> targetUsers;
  final List<String> keyFeatures;
  final List<String> strengths;
  final List<String> limitations;
  final List<String> recommendedUseCases;
  final List<String> unsuitableUseCases;
  final bool apiAvailable;
  final bool localExecution;
  final bool fileUpload;
  final String dataSafetyNote;
  final List<String> badges;
  final String popularityEvidence;
  final List<String> sourceIds;
  final String lastVerified;
  final ContentStatus status;
  final bool isPopular;
  final bool isHiddenGem;

  /// 무료로 사용할 수 있는 요금제가 있는지 여부(freemium 포함).
  bool get isFree => pricingType == 'free' || pricingType == 'freemium';

  factory AiTool.fromJson(Map<String, dynamic> json) {
    return AiTool(
      id: asString(json['id']),
      name: asString(json['name']),
      company: asString(json['company']),
      category: asString(json['category']),
      description: asString(json['description']),
      officialUrl: asString(json['officialUrl']),
      launchDate: asString(json['launchDate']),
      platforms: asStringList(json['platforms']),
      pricingType: asString(json['pricingType']),
      pricingNote: asString(json['pricingNote']),
      koreanSupport: asBool(json['koreanSupport']),
      koreanSupportNote: asString(json['koreanSupportNote']),
      targetUsers: asStringList(json['targetUsers']),
      keyFeatures: asStringList(json['keyFeatures']),
      strengths: asStringList(json['strengths']),
      limitations: asStringList(json['limitations']),
      recommendedUseCases: asStringList(json['recommendedUseCases']),
      unsuitableUseCases: asStringList(json['unsuitableUseCases']),
      apiAvailable: asBool(json['apiAvailable']),
      localExecution: asBool(json['localExecution']),
      fileUpload: asBool(json['fileUpload']),
      dataSafetyNote: asString(json['dataSafetyNote']),
      badges: asStringList(json['badges']),
      popularityEvidence: asString(json['popularityEvidence']),
      sourceIds: asStringList(json['sourceIds']),
      lastVerified: asString(json['lastVerified']),
      status: ContentStatus.fromJson(asStringOrNull(json['status'])),
      isPopular: asBool(json['isPopular']),
      isHiddenGem: asBool(json['isHiddenGem']),
    );
  }
}

/// 카테고리 코드를 한국어 라벨로 변환하는 헬퍼.
String aiToolCategoryLabel(String category) {
  const map = {
    'conversation': '대화형 AI',
    'documents': '문서·업무',
    'image': '이미지 생성',
    'research_education': '연구·교육',
    'coding': '코딩',
    'video': '영상',
    'music_audio': '음악·오디오',
    'translation': '번역',
    'local_offline': '로컬·오프라인',
    'design': '디자인',
    'presentation': '발표자료',
    'marketing': '마케팅',
    'automation': '업무 자동화',
    'data_analysis': '데이터 분석',
    'agriculture': '농업',
    'manufacturing': '제조',
  };
  return map[category] ?? category;
}
