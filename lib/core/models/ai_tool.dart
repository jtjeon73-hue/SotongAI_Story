import '../utils/json_helpers.dart';
import 'api_availability.dart';
import 'content_status.dart';
import 'field_evidence.dart';
import 'korean_support_level.dart';
import 'local_execution_level.dart';
import 'pricing_kind.dart';

/// `assets/data/ai_tools.json`의 개별 AI 도구 항목.
///
/// 요금제·한국어 지원·API 제공·로컬 실행 여부는 단순 불리언으로는 현실을
/// 정확히 표현하기 어렵기 때문에(예: "인터페이스만 한국어" 같은 중간 상태,
/// 아직 확인하지 못한 "unknown" 상태 등) [PricingKind], [KoreanSupportLevel],
/// [ApiAvailability], [LocalExecutionLevel] 열거형을 함께 제공한다.
///
/// 기존 불리언/문자열 필드(`koreanSupport`, `apiAvailable`, `localExecution`,
/// `pricingType`)는 하위 호환을 위해 그대로 유지하며, JSON에 새 필드가 없는
/// 레거시 데이터는 [_migrate...] 계열 함수로 자동 변환된다.
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
    this.koreanSupportLevel = KoreanSupportLevel.unknown,
    this.apiAvailability = ApiAvailability.unknown,
    this.pricingKind = PricingKind.unknown,
    this.localExecutionLevel = LocalExecutionLevel.unknown,
    this.fieldEvidence = const [],
    this.freeTierAvailable,
    this.freeTrialAvailable,
    this.limitsNote = '',
    this.pricingVerifiedAt = '',
  });

  final String id;
  final String name;
  final String company;
  final String category;
  final String description;
  final String officialUrl;
  final String launchDate;
  final List<String> platforms;

  /// @deprecated 자유 문자열 요금제 종류. 신규 코드는 [pricingKind]를 사용할 것.
  final String pricingType;
  final String pricingNote;

  /// @deprecated 한국어 지원 여부(불리언). 신규 코드는 [koreanSupportLevel]을 사용할 것.
  final bool koreanSupport;
  final String koreanSupportNote;
  final List<String> targetUsers;
  final List<String> keyFeatures;
  final List<String> strengths;
  final List<String> limitations;
  final List<String> recommendedUseCases;
  final List<String> unsuitableUseCases;

  /// @deprecated API 제공 여부(불리언). 신규 코드는 [apiAvailability]를 사용할 것.
  final bool apiAvailable;

  /// @deprecated 로컬 실행 여부(불리언). 신규 코드는 [localExecutionLevel]을 사용할 것.
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

  /// 한국어 지원 수준(정밀화된 값). unknown은 "미지원"과 명확히 구분해 표시해야 한다.
  final KoreanSupportLevel koreanSupportLevel;

  /// API 제공 형태(정밀화된 값).
  final ApiAvailability apiAvailability;

  /// 요금제 종류(정밀화된 값).
  final PricingKind pricingKind;

  /// 로컬(오프라인) 실행 지원 수준(정밀화된 값).
  final LocalExecutionLevel localExecutionLevel;

  /// 필드별 검증 근거 목록.
  final List<FieldEvidence> fieldEvidence;

  /// 무료 요금제(영구 무료 티어)가 있는지. 확인되지 않았으면 null.
  final bool? freeTierAvailable;

  /// 무료 체험(트라이얼) 기간이 있는지. 확인되지 않았으면 null.
  final bool? freeTrialAvailable;

  /// 사용량 제한 등 요금제 관련 제약 사항 설명.
  final String limitsNote;

  /// 요금 정보를 마지막으로 확인한 날짜(`yyyy-MM-dd`).
  final String pricingVerifiedAt;

  /// 무료로 사용할 수 있는 요금제가 있는지 여부(freemium 포함).
  ///
  /// [pricingKind]가 unknown이 아니면 그 값을 우선 사용하고, 그렇지 않으면
  /// 레거시 [pricingType] 문자열로 판단한다.
  bool get isFree {
    if (pricingKind != PricingKind.unknown) {
      return pricingKind.hasFreeAccess;
    }
    return pricingType == 'free' || pricingType == 'freemium';
  }

  /// [field]에 대한 실효 검증 상태를 반환한다.
  ///
  /// 해당 필드의 근거가 없으면 [EvidenceStatus.notApplicable]을,
  /// 근거는 있으나 [FieldEvidence.expiresAt]이 오늘보다 과거이면
  /// [EvidenceStatus.verificationRequired](재검증 필요)를 반환한다.
  EvidenceStatus effectiveFieldStatus(String field) {
    for (final evidence in fieldEvidence) {
      if (evidence.field == field) {
        return evidence.effectiveStatus;
      }
    }
    return EvidenceStatus.notApplicable;
  }

  factory AiTool.fromJson(Map<String, dynamic> json) {
    final legacyKoreanSupport = json.containsKey('koreanSupport')
        ? asBool(json['koreanSupport'])
        : null;
    final legacyApiAvailable = json.containsKey('apiAvailable')
        ? asBool(json['apiAvailable'])
        : null;
    final legacyLocalExecution = json.containsKey('localExecution')
        ? asBool(json['localExecution'])
        : null;
    final koreanSupportNote = asString(json['koreanSupportNote']);
    final pricingType = asString(json['pricingType']);

    return AiTool(
      id: asString(json['id']),
      name: asString(json['name']),
      company: asString(json['company']),
      category: asString(json['category']),
      description: asString(json['description']),
      officialUrl: asString(json['officialUrl']),
      launchDate: asString(json['launchDate']),
      platforms: asStringList(json['platforms']),
      pricingType: pricingType,
      pricingNote: asString(json['pricingNote']),
      koreanSupport: legacyKoreanSupport ?? false,
      koreanSupportNote: koreanSupportNote,
      targetUsers: asStringList(json['targetUsers']),
      keyFeatures: asStringList(json['keyFeatures']),
      strengths: asStringList(json['strengths']),
      limitations: asStringList(json['limitations']),
      recommendedUseCases: asStringList(json['recommendedUseCases']),
      unsuitableUseCases: asStringList(json['unsuitableUseCases']),
      apiAvailable: legacyApiAvailable ?? false,
      localExecution: legacyLocalExecution ?? false,
      fileUpload: asBool(json['fileUpload']),
      dataSafetyNote: asString(json['dataSafetyNote']),
      badges: asStringList(json['badges']),
      popularityEvidence: asString(json['popularityEvidence']),
      sourceIds: asStringList(json['sourceIds']),
      lastVerified: asString(json['lastVerified']),
      status: ContentStatus.fromJson(asStringOrNull(json['status'])),
      isPopular: asBool(json['isPopular']),
      isHiddenGem: asBool(json['isHiddenGem']),
      koreanSupportLevel: _migrateKoreanSupportLevel(
        json,
        legacyKoreanSupport,
        koreanSupportNote,
      ),
      apiAvailability: _migrateApiAvailability(json, legacyApiAvailable),
      pricingKind: _migratePricingKind(json, pricingType),
      localExecutionLevel: _migrateLocalExecutionLevel(
        json,
        legacyLocalExecution,
      ),
      fieldEvidence: asFieldEvidenceList(json['fieldEvidence']),
      freeTierAvailable: asTriStateBool(json['freeTierAvailable']),
      freeTrialAvailable: asTriStateBool(json['freeTrialAvailable']),
      limitsNote: asString(json['limitsNote']),
      pricingVerifiedAt: asString(json['pricingVerifiedAt']),
    );
  }

  static KoreanSupportLevel _migrateKoreanSupportLevel(
    Map<String, dynamic> json,
    bool? legacyKoreanSupport,
    String note,
  ) {
    final raw = asStringOrNull(json['koreanSupportLevel']);
    if (raw != null) return KoreanSupportLevel.fromJson(raw);

    KoreanSupportLevel level;
    if (legacyKoreanSupport == null) {
      level = KoreanSupportLevel.unknown;
    } else {
      level = legacyKoreanSupport
          ? KoreanSupportLevel.full
          : KoreanSupportLevel.none;
    }
    if (note.contains('확인') || note.contains('필요')) {
      level = KoreanSupportLevel.unknown;
    }
    return level;
  }

  static ApiAvailability _migrateApiAvailability(
    Map<String, dynamic> json,
    bool? legacyApiAvailable,
  ) {
    final raw = asStringOrNull(json['apiAvailability']);
    if (raw != null) return ApiAvailability.fromJson(raw);

    if (legacyApiAvailable == null) return ApiAvailability.unknown;
    return legacyApiAvailable ? ApiAvailability.official : ApiAvailability.none;
  }

  static PricingKind _migratePricingKind(
    Map<String, dynamic> json,
    String pricingType,
  ) {
    final raw = asStringOrNull(json['pricingKind']);
    if (raw != null) return PricingKind.fromJson(raw);
    if (pricingType.isEmpty) return PricingKind.unknown;
    return PricingKind.fromLegacyPricingType(pricingType);
  }

  static LocalExecutionLevel _migrateLocalExecutionLevel(
    Map<String, dynamic> json,
    bool? legacyLocalExecution,
  ) {
    final raw = asStringOrNull(json['localExecutionLevel']);
    if (raw != null) return LocalExecutionLevel.fromJson(raw);

    if (legacyLocalExecution == null) return LocalExecutionLevel.unknown;
    return legacyLocalExecution
        ? LocalExecutionLevel.supported
        : LocalExecutionLevel.notSupported;
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
