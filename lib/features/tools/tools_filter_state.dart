import '../../core/models/ai_tool.dart';
import '../../core/models/api_availability.dart';
import '../../core/models/content_status.dart';
import '../../core/models/korean_support_level.dart';
import '../../core/models/local_execution_level.dart';
import '../../core/models/pricing_kind.dart';
import '../../core/utils/search_utils.dart';

/// AI 툴 탐색 페이지의 최근 검증 기간 필터.
enum VerifiedPeriod {
  all,
  days30,
  days90,
  days180,
  days365;

  static VerifiedPeriod fromParam(String? value) {
    switch (value) {
      case '30':
        return VerifiedPeriod.days30;
      case '90':
        return VerifiedPeriod.days90;
      case '180':
        return VerifiedPeriod.days180;
      case '365':
        return VerifiedPeriod.days365;
      default:
        return VerifiedPeriod.all;
    }
  }

  String? get param {
    switch (this) {
      case VerifiedPeriod.all:
        return null;
      case VerifiedPeriod.days30:
        return '30';
      case VerifiedPeriod.days90:
        return '90';
      case VerifiedPeriod.days180:
        return '180';
      case VerifiedPeriod.days365:
        return '365';
    }
  }

  String get label {
    switch (this) {
      case VerifiedPeriod.all:
        return '전체 기간';
      case VerifiedPeriod.days30:
        return '최근 30일';
      case VerifiedPeriod.days90:
        return '최근 90일';
      case VerifiedPeriod.days180:
        return '최근 180일';
      case VerifiedPeriod.days365:
        return '최근 1년';
    }
  }

  int? get days {
    switch (this) {
      case VerifiedPeriod.all:
        return null;
      case VerifiedPeriod.days30:
        return 30;
      case VerifiedPeriod.days90:
        return 90;
      case VerifiedPeriod.days180:
        return 180;
      case VerifiedPeriod.days365:
        return 365;
    }
  }
}

/// AI 툴 탐색 페이지의 정렬 기준.
enum ToolsSort {
  name,
  recentVerified,
  category,
  beginnerFriendly,
  verificationStatus;

  static ToolsSort fromParam(String? value) {
    switch (value) {
      case 'recent':
        return ToolsSort.recentVerified;
      case 'category':
        return ToolsSort.category;
      case 'beginner':
        return ToolsSort.beginnerFriendly;
      case 'status':
        return ToolsSort.verificationStatus;
      default:
        return ToolsSort.name;
    }
  }

  String get param {
    switch (this) {
      case ToolsSort.name:
        return 'name';
      case ToolsSort.recentVerified:
        return 'recent';
      case ToolsSort.category:
        return 'category';
      case ToolsSort.beginnerFriendly:
        return 'beginner';
      case ToolsSort.verificationStatus:
        return 'status';
    }
  }

  String get label {
    switch (this) {
      case ToolsSort.name:
        return '이름순';
      case ToolsSort.recentVerified:
        return '최근 검증순';
      case ToolsSort.category:
        return '카테고리순';
      case ToolsSort.beginnerFriendly:
        return '입문자 추천순';
      case ToolsSort.verificationStatus:
        return '검증 상태순';
    }
  }
}

/// AI 툴 탐색 페이지의 필터·정렬·검색 상태.
///
/// URL 쿼리 파라미터와 1:1로 대응하도록 설계해, [ToolsFilterState.fromQueryParameters]
/// 로 URL을 상태로 복원하고 [toQueryParameters]로 다시 URL로 되돌릴 수 있다.
class ToolsFilterState {
  const ToolsFilterState({
    this.query = '',
    this.category,
    this.pricingKind,
    this.freeTierOnly = false,
    this.freeTrialOnly = false,
    this.koreanLevel,
    this.platform,
    this.targetUser,
    this.apiAvailability,
    this.localExecution,
    this.fileUploadOnly = false,
    this.audience,
    this.status,
    this.verifiedPeriod = VerifiedPeriod.all,
    this.sort = ToolsSort.name,
  });

  final String query;
  final String? category;
  final PricingKind? pricingKind;
  final bool freeTierOnly;
  final bool freeTrialOnly;
  final KoreanSupportLevel? koreanLevel;
  final String? platform;
  final String? targetUser;
  final ApiAvailability? apiAvailability;
  final LocalExecutionLevel? localExecution;
  final bool fileUploadOnly;
  final String? audience;
  final ContentStatus? status;
  final VerifiedPeriod verifiedPeriod;
  final ToolsSort sort;

  /// 검색어를 제외하고 필터가 하나라도 켜져 있는지 여부.
  bool get hasActiveFilters =>
      category != null ||
      pricingKind != null ||
      freeTierOnly ||
      freeTrialOnly ||
      koreanLevel != null ||
      platform != null ||
      targetUser != null ||
      apiAvailability != null ||
      localExecution != null ||
      fileUploadOnly ||
      audience != null ||
      status != null ||
      verifiedPeriod != VerifiedPeriod.all;

  bool get hasAnyActivity => hasActiveFilters || query.trim().isNotEmpty;

  ToolsFilterState copyWith({
    String? query,
    Object? category = _unset,
    Object? pricingKind = _unset,
    bool? freeTierOnly,
    bool? freeTrialOnly,
    Object? koreanLevel = _unset,
    Object? platform = _unset,
    Object? targetUser = _unset,
    Object? apiAvailability = _unset,
    Object? localExecution = _unset,
    bool? fileUploadOnly,
    Object? audience = _unset,
    Object? status = _unset,
    VerifiedPeriod? verifiedPeriod,
    ToolsSort? sort,
  }) {
    return ToolsFilterState(
      query: query ?? this.query,
      category: category == _unset ? this.category : category as String?,
      pricingKind: pricingKind == _unset
          ? this.pricingKind
          : pricingKind as PricingKind?,
      freeTierOnly: freeTierOnly ?? this.freeTierOnly,
      freeTrialOnly: freeTrialOnly ?? this.freeTrialOnly,
      koreanLevel: koreanLevel == _unset
          ? this.koreanLevel
          : koreanLevel as KoreanSupportLevel?,
      platform: platform == _unset ? this.platform : platform as String?,
      targetUser: targetUser == _unset
          ? this.targetUser
          : targetUser as String?,
      apiAvailability: apiAvailability == _unset
          ? this.apiAvailability
          : apiAvailability as ApiAvailability?,
      localExecution: localExecution == _unset
          ? this.localExecution
          : localExecution as LocalExecutionLevel?,
      fileUploadOnly: fileUploadOnly ?? this.fileUploadOnly,
      audience: audience == _unset ? this.audience : audience as String?,
      status: status == _unset ? this.status : status as ContentStatus?,
      verifiedPeriod: verifiedPeriod ?? this.verifiedPeriod,
      sort: sort ?? this.sort,
    );
  }

  static const Object _unset = Object();

  /// 필터를 모두 초기화하되 검색어는 유지한 상태를 반환한다.
  ToolsFilterState clearFilters() => ToolsFilterState(query: query);

  /// 검색어까지 포함해 완전히 초기 상태로 되돌린다.
  ToolsFilterState clearAll() => const ToolsFilterState();

  /// go_router의 URL 쿼리 파라미터 맵을 상태로 복원한다.
  factory ToolsFilterState.fromQueryParameters(Map<String, String> params) {
    return ToolsFilterState(
      query: params['q'] ?? '',
      category: params['category'],
      pricingKind: params['pricing'] == null
          ? null
          : PricingKind.fromJson(params['pricing']),
      freeTierOnly: params['freeTier'] == '1',
      freeTrialOnly: params['freeTrial'] == '1',
      koreanLevel: params['korean'] == null
          ? null
          : KoreanSupportLevel.fromJson(params['korean']),
      platform: params['platform'],
      targetUser: params['audience2'],
      apiAvailability: params['api'] == null
          ? null
          : ApiAvailability.fromJson(params['api']),
      localExecution: params['local'] == null
          ? null
          : LocalExecutionLevel.fromJson(params['local']),
      fileUploadOnly: params['fileUpload'] == '1',
      audience: params['audience'],
      status: params['status'] == null
          ? null
          : ContentStatus.fromJson(params['status']),
      verifiedPeriod: VerifiedPeriod.fromParam(params['period']),
      sort: ToolsSort.fromParam(params['sort']),
    );
  }

  /// 상태를 go_router `context.go()`에 넘길 수 있는 쿼리 파라미터 맵으로
  /// 변환한다. 값이 없는(=기본값) 필터는 URL을 깔끔하게 유지하기 위해 맵에서
  /// 제외한다.
  Map<String, String> toQueryParameters() {
    final map = <String, String>{};
    if (query.trim().isNotEmpty) map['q'] = query.trim();
    if (category != null) map['category'] = category!;
    if (pricingKind != null) map['pricing'] = pricingKind!.jsonValue;
    if (freeTierOnly) map['freeTier'] = '1';
    if (freeTrialOnly) map['freeTrial'] = '1';
    if (koreanLevel != null) map['korean'] = koreanLevel!.jsonValue;
    if (platform != null) map['platform'] = platform!;
    if (targetUser != null) map['audience2'] = targetUser!;
    if (apiAvailability != null) map['api'] = apiAvailability!.jsonValue;
    if (localExecution != null) map['local'] = localExecution!.jsonValue;
    if (fileUploadOnly) map['fileUpload'] = '1';
    if (audience != null) map['audience'] = audience!;
    if (status != null) map['status'] = status!.name;
    if (verifiedPeriod.param != null) map['period'] = verifiedPeriod.param!;
    if (sort != ToolsSort.name) map['sort'] = sort.param;
    return map;
  }
}

/// [tool]이 [audience](개인/기업/공공)와 관련된 대상 사용자를 갖는지 확인한다.
bool toolMatchesAudience(AiTool tool, String audience) =>
    tool.targetUsers.any((u) => u.contains(audience));

/// [tool]이 초보자에게 추천할 만한지 대략적으로 판단한다(targetUsers/badges 기반).
bool toolIsBeginnerFriendly(AiTool tool) {
  const beginnerKeywords = ['일반 사용자', '학생', '초보', '누구나'];
  return tool.targetUsers.any(
        (u) => beginnerKeywords.any((k) => u.contains(k)),
      ) ||
      tool.badges.any((b) => beginnerKeywords.any((k) => b.contains(k)));
}

const Map<ContentStatus, int> _statusSortRank = {
  ContentStatus.verified: 0,
  ContentStatus.active: 1,
  ContentStatus.partiallyVerified: 2,
  ContentStatus.verificationRequired: 3,
  ContentStatus.expired: 4,
  ContentStatus.forecast: 5,
  ContentStatus.inactive: 6,
  ContentStatus.unknown: 7,
};

/// [state]에 따라 [tools]를 필터링하고 정렬한 결과를 반환한다.
///
/// UI와 분리된 순수 함수라 위젯 테스트 없이 단위 테스트할 수 있다.
List<AiTool> applyToolsFilter(List<AiTool> tools, ToolsFilterState state) {
  final q = normalizeSearchQuery(state.query);

  var filtered = tools.where((tool) {
    if (state.category != null && tool.category != state.category) {
      return false;
    }
    if (state.pricingKind != null && tool.pricingKind != state.pricingKind) {
      return false;
    }
    if (state.freeTierOnly && tool.freeTierAvailable != true) return false;
    if (state.freeTrialOnly && tool.freeTrialAvailable != true) return false;
    if (state.koreanLevel != null &&
        tool.koreanSupportLevel != state.koreanLevel) {
      return false;
    }
    if (state.platform != null && !tool.platforms.contains(state.platform)) {
      return false;
    }
    if (state.targetUser != null &&
        !tool.targetUsers.contains(state.targetUser)) {
      return false;
    }
    if (state.apiAvailability != null &&
        tool.apiAvailability != state.apiAvailability) {
      return false;
    }
    if (state.localExecution != null &&
        tool.localExecutionLevel != state.localExecution) {
      return false;
    }
    if (state.fileUploadOnly && !tool.fileUpload) return false;
    if (state.audience != null &&
        !toolMatchesAudience(tool, state.audience!)) {
      return false;
    }
    if (state.status != null && tool.status != state.status) return false;
    final days = state.verifiedPeriod.days;
    if (days != null) {
      final verified = DateTime.tryParse(tool.lastVerified);
      if (verified == null) return false;
      final age = DateTime.now().difference(verified).inDays;
      if (age > days) return false;
    }
    if (q.isEmpty) return true;
    return [
      tool.name,
      tool.company,
      tool.description,
      aiToolCategoryLabel(tool.category),
      ...tool.keyFeatures,
      ...tool.strengths,
      ...tool.recommendedUseCases,
      ...tool.targetUsers,
      ...tool.badges,
    ].any((f) => normalizeSearchQuery(f).contains(q));
  }).toList();

  switch (state.sort) {
    case ToolsSort.name:
      filtered.sort((a, b) => a.name.compareTo(b.name));
    case ToolsSort.recentVerified:
      filtered.sort((a, b) => b.lastVerified.compareTo(a.lastVerified));
    case ToolsSort.category:
      filtered.sort((a, b) => a.category.compareTo(b.category));
    case ToolsSort.beginnerFriendly:
      filtered.sort((a, b) {
        final aBeginner = toolIsBeginnerFriendly(a) ? 0 : 1;
        final bBeginner = toolIsBeginnerFriendly(b) ? 0 : 1;
        if (aBeginner != bBeginner) return aBeginner.compareTo(bBeginner);
        return a.name.compareTo(b.name);
      });
    case ToolsSort.verificationStatus:
      filtered.sort((a, b) {
        final rankA = _statusSortRank[a.status] ?? 99;
        final rankB = _statusSortRank[b.status] ?? 99;
        if (rankA != rankB) return rankA.compareTo(rankB);
        return a.name.compareTo(b.name);
      });
  }

  return filtered;
}
