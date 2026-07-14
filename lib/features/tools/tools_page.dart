import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../core/constants/route_paths.dart';
import '../../core/models/ai_tool.dart';
import '../../core/models/api_availability.dart';
import '../../core/models/content_status.dart';
import '../../core/models/korean_support_level.dart';
import '../../core/models/local_execution_level.dart';
import '../../core/models/pricing_kind.dart';
import '../../core/repositories/content_repository.dart';
import '../../shared/layout/responsive_layout.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/deferred_content.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/filter_chips.dart';
import '../../shared/widgets/responsive_grid.dart';
import '../../shared/widgets/search_field.dart';
import 'tools_filter_state.dart';
import 'widgets/tool_card.dart';

/// AI 툴 탐색 페이지.
///
/// 카테고리, 요금제 종류, 한국어 지원 수준, 플랫폼, 대상 사용자, API 제공,
/// 로컬 실행, 파일 업로드, 검증 상태, 최근 검증 기간 등 다양한 필터와
/// 정렬을 제공한다. 모든 필터 상태는 URL 쿼리 파라미터에 반영되어 링크
/// 공유·새로고침 시에도 유지된다.
class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key, this.initialParams = const {}});

  final Map<String, String> initialParams;

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialParams['q'] ?? '',
  );
  late ToolsFilterState _filter = ToolsFilterState.fromQueryParameters(
    widget.initialParams,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _update(ToolsFilterState Function(ToolsFilterState) transform) {
    setState(() {
      _filter = transform(_filter);
    });
    final params = _filter.toQueryParameters();
    final query = params.isEmpty
        ? RoutePaths.tools
        : Uri(path: RoutePaths.tools, queryParameters: params).toString();
    context.go(query);
  }

  @override
  Widget build(BuildContext context) {
    final repository = AppScope.of(context).repository;
    return DeferredContent<void>(
      load: repository.ensureTools,
      loadingMessage: 'AI 도구를 불러오는 중입니다...',
      builder: (context, _) => _buildContent(context, repository),
    );
  }

  Widget _buildContent(BuildContext context, ContentRepository repository) {
    final tools = repository.tools;
    final filtered = applyToolsFilter(tools, _filter);
    final isDesktop = ResponsiveLayout.isDesktopOf(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeader(
            title: 'AI 툴 탐색',
            description:
                '목적과 조건에 맞는 AI 도구를 요금제, 한국어 지원 수준, 플랫폼, API 제공 여부 등 '
                '다양한 조건으로 찾아보세요.',
            searchField: SearchField(
              controller: _controller,
              hintText: '도구 이름·회사·기능으로 검색 (예: 챗GPT, 미드저니, 코딩)',
              onChanged: (value) => _update((f) => f.copyWith(query: value)),
            ),
          ),
          if (isDesktop)
            _ToolsFilterPanel(tools: tools, filter: _filter, onChange: _update)
          else
            _MobileFilterBar(
              tools: tools,
              filter: _filter,
              onChange: _update,
              resultCount: filtered.length,
            ),
          const SizedBox(height: 12),
          _ActiveFilterChips(filter: _filter, onChange: _update),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '검색 결과 ${filtered.length}개',
                style: AppTextStyles.small.copyWith(color: AppColors.muted),
              ),
              const Spacer(),
              if (!isDesktop) const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            EmptyStateView(
              icon: Icons.search_off_rounded,
              title: '조건에 맞는 도구가 없습니다',
              message: _filter.hasAnyActivity
                  ? '검색어나 선택한 필터를 줄이면 더 많은 결과를 볼 수 있습니다.'
                  : '표시할 도구 데이터가 없습니다.',
              action: _filter.hasAnyActivity
                  ? OutlinedButton(
                      onPressed: () => _update((f) => f.clearAll()),
                      child: const Text('모든 조건 지우기'),
                    )
                  : null,
            )
          else
            ResponsiveGrid(
              useAutoHeight: true,
              children: filtered
                  .map<Widget>((tool) => ToolCard(tool: tool))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

/// 데스크톱/태블릿에서 인라인으로 표시되는 필터 패널.
class _ToolsFilterPanel extends StatelessWidget {
  const _ToolsFilterPanel({
    required this.tools,
    required this.filter,
    required this.onChange,
  });

  final List<AiTool> tools;
  final ToolsFilterState filter;
  final void Function(ToolsFilterState Function(ToolsFilterState)) onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: _ToolsFilterFields(tools: tools, filter: filter, onChange: onChange),
    );
  }
}

/// 모바일에서 결과 수 + "필터" 버튼을 보여주고, 탭하면 [showModalBottomSheet]로
/// 전체 필터 패널을 연다.
class _MobileFilterBar extends StatelessWidget {
  const _MobileFilterBar({
    required this.tools,
    required this.filter,
    required this.onChange,
    required this.resultCount,
  });

  final List<AiTool> tools;
  final ToolsFilterState filter;
  final void Function(ToolsFilterState Function(ToolsFilterState)) onChange;
  final int resultCount;

  void _openSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Text('필터·정렬', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  _ToolsFilterFields(
                    tools: tools,
                    filter: filter,
                    onChange: onChange,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('결과 보기'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '결과 $resultCount개',
            style: AppTextStyles.bodyStrong,
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => _openSheet(context),
          icon: const Icon(Icons.tune_rounded, size: 18),
          label: Text(filter.hasActiveFilters ? '필터·정렬 (적용됨)' : '필터·정렬'),
        ),
      ],
    );
  }
}

/// 데스크톱 패널과 모바일 바텀시트가 공유하는 실제 필터 컨트롤 목록.
class _ToolsFilterFields extends StatelessWidget {
  const _ToolsFilterFields({
    required this.tools,
    required this.filter,
    required this.onChange,
  });

  final List<AiTool> tools;
  final ToolsFilterState filter;
  final void Function(ToolsFilterState Function(ToolsFilterState)) onChange;

  @override
  Widget build(BuildContext context) {
    final categories = tools.map((t) => t.category).toSet().toList()..sort();
    final platforms = tools.expand((t) => t.platforms).toSet().toList()
      ..sort();
    final targetUsers = tools.expand((t) => t.targetUsers).toSet().toList()
      ..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('무료 티어 있음'),
              selected: filter.freeTierOnly,
              onSelected: (v) =>
                  onChange((f) => f.copyWith(freeTierOnly: v)),
            ),
            FilterChip(
              label: const Text('무료 체험 가능'),
              selected: filter.freeTrialOnly,
              onSelected: (v) =>
                  onChange((f) => f.copyWith(freeTrialOnly: v)),
            ),
            FilterChip(
              label: const Text('파일 업로드 지원'),
              selected: filter.fileUploadOnly,
              onSelected: (v) =>
                  onChange((f) => f.copyWith(fileUploadOnly: v)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _FilterSection(
          title: '카테고리',
          child: FilterChipsBar<String>(
            options: categories
                .map((c) => FilterChipOption(value: c, label: aiToolCategoryLabel(c)))
                .toList(),
            selected: filter.category,
            onSelected: (v) => onChange((f) => f.copyWith(category: v)),
          ),
        ),
        _FilterSection(
          title: '요금제 유형',
          child: FilterChipsBar<PricingKind>(
            options: PricingKind.values
                .where((p) => p != PricingKind.unknown)
                .map((p) => FilterChipOption(value: p, label: p.label))
                .toList(),
            selected: filter.pricingKind,
            onSelected: (v) => onChange((f) => f.copyWith(pricingKind: v)),
          ),
        ),
        _FilterSection(
          title: '한국어 지원 수준',
          child: FilterChipsBar<KoreanSupportLevel>(
            options: KoreanSupportLevel.values
                .map((k) => FilterChipOption(value: k, label: k.label))
                .toList(),
            selected: filter.koreanLevel,
            onSelected: (v) => onChange((f) => f.copyWith(koreanLevel: v)),
          ),
        ),
        _FilterSection(
          title: 'API 제공',
          child: FilterChipsBar<ApiAvailability>(
            options: ApiAvailability.values
                .map((a) => FilterChipOption(value: a, label: a.label))
                .toList(),
            selected: filter.apiAvailability,
            onSelected: (v) => onChange((f) => f.copyWith(apiAvailability: v)),
          ),
        ),
        _FilterSection(
          title: '로컬 실행',
          child: FilterChipsBar<LocalExecutionLevel>(
            options: LocalExecutionLevel.values
                .map((l) => FilterChipOption(value: l, label: l.label))
                .toList(),
            selected: filter.localExecution,
            onSelected: (v) => onChange((f) => f.copyWith(localExecution: v)),
          ),
        ),
        _FilterSection(
          title: '대상(개인/기업/공공)',
          child: FilterChipsBar<String>(
            options: const [
              FilterChipOption(value: '개인', label: '개인'),
              FilterChipOption(value: '기업', label: '기업'),
              FilterChipOption(value: '공공', label: '공공'),
            ],
            selected: filter.audience,
            onSelected: (v) => onChange((f) => f.copyWith(audience: v)),
          ),
        ),
        if (platforms.isNotEmpty)
          _FilterSection(
            title: '플랫폼',
            child: FilterChipsBar<String>(
              options: platforms
                  .map((p) => FilterChipOption(value: p, label: p))
                  .toList(),
              selected: filter.platform,
              onSelected: (v) => onChange((f) => f.copyWith(platform: v)),
            ),
          ),
        if (targetUsers.isNotEmpty)
          _FilterSection(
            title: '대상 사용자',
            child: FilterChipsBar<String>(
              options: targetUsers
                  .map((u) => FilterChipOption(value: u, label: u))
                  .toList(),
              selected: filter.targetUser,
              onSelected: (v) => onChange((f) => f.copyWith(targetUser: v)),
            ),
          ),
        _FilterSection(
          title: '검증 상태',
          child: FilterChipsBar<ContentStatus>(
            options: const [
              FilterChipOption(value: ContentStatus.verified, label: '검증 완료'),
              FilterChipOption(
                value: ContentStatus.partiallyVerified,
                label: '부분 검증',
              ),
              FilterChipOption(
                value: ContentStatus.verificationRequired,
                label: '검증 필요',
              ),
              FilterChipOption(value: ContentStatus.active, label: '서비스 중'),
              FilterChipOption(value: ContentStatus.inactive, label: '서비스 종료'),
            ],
            selected: filter.status,
            onSelected: (v) => onChange((f) => f.copyWith(status: v)),
          ),
        ),
        _FilterSection(
          title: '최근 검증 기간',
          child: FilterChipsBar<VerifiedPeriod>(
            options: VerifiedPeriod.values
                .where((p) => p != VerifiedPeriod.all)
                .map((p) => FilterChipOption(value: p, label: p.label))
                .toList(),
            selected: filter.verifiedPeriod == VerifiedPeriod.all
                ? null
                : filter.verifiedPeriod,
            onSelected: (v) => onChange(
              (f) => f.copyWith(verifiedPeriod: v ?? VerifiedPeriod.all),
            ),
          ),
        ),
        _FilterSection(
          title: '정렬',
          child: FilterChipsBar<ToolsSort>(
            options: ToolsSort.values
                .map((s) => FilterChipOption(value: s, label: s.label))
                .toList(),
            selected: filter.sort == ToolsSort.name ? null : filter.sort,
            onSelected: (v) => onChange((f) => f.copyWith(sort: v ?? ToolsSort.name)),
            allLabel: '이름순',
          ),
        ),
      ],
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              title,
              style: AppTextStyles.small.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// 현재 적용된 필터를 칩 형태로 나열하고, 개별 제거 및 전체 지우기를 제공한다.
class _ActiveFilterChips extends StatelessWidget {
  const _ActiveFilterChips({required this.filter, required this.onChange});

  final ToolsFilterState filter;
  final void Function(ToolsFilterState Function(ToolsFilterState)) onChange;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    void addChip(String label, ToolsFilterState Function(ToolsFilterState) clear) {
      chips.add(
        InputChip(
          label: Text(label),
          onDeleted: () => onChange(clear),
          deleteIconColor: AppColors.muted,
        ),
      );
    }

    if (filter.category != null) {
      addChip(
        aiToolCategoryLabel(filter.category!),
        (f) => f.copyWith(category: null),
      );
    }
    if (filter.pricingKind != null) {
      addChip(filter.pricingKind!.label, (f) => f.copyWith(pricingKind: null));
    }
    if (filter.freeTierOnly) {
      addChip('무료 티어 있음', (f) => f.copyWith(freeTierOnly: false));
    }
    if (filter.freeTrialOnly) {
      addChip('무료 체험 가능', (f) => f.copyWith(freeTrialOnly: false));
    }
    if (filter.koreanLevel != null) {
      addChip(filter.koreanLevel!.label, (f) => f.copyWith(koreanLevel: null));
    }
    if (filter.platform != null) {
      addChip(filter.platform!, (f) => f.copyWith(platform: null));
    }
    if (filter.targetUser != null) {
      addChip(filter.targetUser!, (f) => f.copyWith(targetUser: null));
    }
    if (filter.apiAvailability != null) {
      addChip(
        filter.apiAvailability!.label,
        (f) => f.copyWith(apiAvailability: null),
      );
    }
    if (filter.localExecution != null) {
      addChip(
        filter.localExecution!.label,
        (f) => f.copyWith(localExecution: null),
      );
    }
    if (filter.fileUploadOnly) {
      addChip('파일 업로드 지원', (f) => f.copyWith(fileUploadOnly: false));
    }
    if (filter.audience != null) {
      addChip('대상: ${filter.audience}', (f) => f.copyWith(audience: null));
    }
    if (filter.status != null) {
      addChip(filter.status!.label, (f) => f.copyWith(status: null));
    }
    if (filter.verifiedPeriod != VerifiedPeriod.all) {
      addChip(
        filter.verifiedPeriod.label,
        (f) => f.copyWith(verifiedPeriod: VerifiedPeriod.all),
      );
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ...chips,
        ActionChip(
          avatar: const Icon(Icons.clear_rounded, size: 16),
          label: const Text('필터 초기화'),
          onPressed: () => onChange((f) => f.clearFilters()),
        ),
      ],
    );
  }
}
