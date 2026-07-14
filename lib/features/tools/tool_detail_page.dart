import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/route_paths.dart';
import '../../core/models/ai_tool.dart';
import '../../core/models/api_availability.dart';
import '../../core/models/field_evidence.dart';
import '../../core/models/korean_support_level.dart';
import '../../core/models/local_execution_level.dart';
import '../../core/repositories/content_repository.dart';
import '../../core/services/link_service.dart';
import '../../core/storage/favorites_storage.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/deferred_content.dart';
import '../../shared/widgets/detail_page_scaffold.dart';
import '../../shared/widgets/empty_state.dart';

/// AI 도구 상세 페이지.
class ToolDetailPage extends StatelessWidget {
  const ToolDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final repository = AppScope.of(context).repository;
    // 목록 페이지를 거치지 않고 상세 경로로 바로 진입(딥링크)하는 경우를
    // 대비해, 상세 페이지에서도 도구 데이터 로드를 직접 보장한다.
    return DeferredContent<void>(
      load: repository.ensureTools,
      loadingMessage: '도구 정보를 불러오는 중입니다...',
      builder: (context, _) => _buildContent(context, repository),
    );
  }

  Widget _buildContent(BuildContext context, ContentRepository repository) {
    final tool = repository.toolById(id);

    if (tool == null) {
      return const EmptyStateView(
        icon: Icons.search_off_rounded,
        title: '도구를 찾을 수 없습니다',
      );
    }

    final shareUrl =
        '${AppConstants.firebaseHostingUrl}${RoutePaths.toolsDetailOf(tool.id)}';

    return DetailPageScaffold(
      breadcrumb: [
        const DetailBreadcrumbItem(label: '홈', route: RoutePaths.home),
        const DetailBreadcrumbItem(label: 'AI 툴 탐색', route: RoutePaths.tools),
        DetailBreadcrumbItem(label: tool.name),
      ],
      typeBadge: 'AI 툴',
      title: tool.name,
      summary: tool.description,
      status: tool.status,
      verifiedAt: tool.lastVerified,
      favoriteCategory: FavoriteCategory.tools,
      favoriteId: tool.id,
      shareUrl: shareUrl,
      shareText: tool.description,
      pageContext: 'AI 툴 상세: ${tool.name}',
      sourceIds: tool.sourceIds,
      resolveSource: repository.sourceById,
      infoChips: [
        _InfoChip(icon: Icons.apartment_rounded, label: tool.company),
        _InfoChip(
          icon: Icons.category_rounded,
          label: aiToolCategoryLabel(tool.category),
        ),
        _InfoChip(
          icon: Icons.payments_outlined,
          label: tool.pricingKind.label,
        ),
        _InfoChip(
          icon: Icons.translate_rounded,
          label: tool.koreanSupportLevel.label,
          muted: tool.koreanSupportLevel == KoreanSupportLevel.unknown,
        ),
        _InfoChip(
          icon: Icons.api_rounded,
          label: tool.apiAvailability.label,
          muted: tool.apiAvailability == ApiAvailability.unknown,
        ),
        _InfoChip(
          icon: Icons.computer_rounded,
          label: tool.localExecutionLevel.label,
          muted: tool.localExecutionLevel == LocalExecutionLevel.unknown,
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: () => LinkService.openUrl(context, tool.officialUrl),
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('공식 사이트 방문'),
          ),
          const SizedBox(height: 24),
          if (tool.keyFeatures.isNotEmpty)
            _BulletSection(
              title: '주요 기능',
              items: tool.keyFeatures,
              icon: Icons.star_outline_rounded,
            ),
          if (tool.strengths.isNotEmpty)
            _BulletSection(
              title: '강점',
              items: tool.strengths,
              icon: Icons.thumb_up_outlined,
              color: AppColors.success,
            ),
          if (tool.limitations.isNotEmpty)
            _BulletSection(
              title: '한계',
              items: tool.limitations,
              icon: Icons.thumb_down_outlined,
              color: AppColors.error,
            ),
          if (tool.recommendedUseCases.isNotEmpty)
            _BulletSection(
              title: '추천 활용',
              items: tool.recommendedUseCases,
              icon: Icons.check_circle_outline,
              color: AppColors.blue,
            ),
          if (tool.unsuitableUseCases.isNotEmpty)
            _BulletSection(
              title: '적합하지 않은 활용',
              items: tool.unsuitableUseCases,
              icon: Icons.block_rounded,
              color: AppColors.muted,
            ),
          _Section(title: '요금 안내', body: tool.pricingNote),
          if (tool.limitsNote.isNotEmpty)
            _Section(title: '이용 제한 사항', body: tool.limitsNote),
          if (tool.freeTierAvailable != null || tool.freeTrialAvailable != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (tool.freeTierAvailable == true)
                    const _MiniInfoBadge(label: '무료 티어 있음', positive: true),
                  if (tool.freeTierAvailable == false)
                    const _MiniInfoBadge(label: '무료 티어 없음', positive: false),
                  if (tool.freeTrialAvailable == true)
                    const _MiniInfoBadge(label: '무료 체험 가능', positive: true),
                  if (tool.freeTrialAvailable == false)
                    const _MiniInfoBadge(label: '무료 체험 없음', positive: false),
                ],
              ),
            ),
          _Section(title: '데이터 안전 참고', body: tool.dataSafetyNote),
          if (tool.fieldEvidence.isNotEmpty)
            _FieldEvidenceSection(evidence: tool.fieldEvidence),
          if (tool.badges.isNotEmpty) ...[
            Text(
              '배지',
              style: AppTextStyles.small.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tool.badges.map((b) => Chip(label: Text(b))).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    if (body.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text(
            body,
            style: AppTextStyles.body.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _BulletSection extends StatelessWidget {
  const _BulletSection({
    required this.title,
    required this.items,
    required this.icon,
    this.color = AppColors.blue,
  });

  final String title;
  final List<String> items;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: 8),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item, style: AppTextStyles.body)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, this.muted = false});

  final IconData icon;
  final String label;

  /// true면 "확인 필요(unknown)" 등 불확실한 값임을 시각적으로 구분해 표시한다.
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final color = muted ? AppColors.gold : AppColors.text;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: muted ? AppColors.gold : AppColors.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            muted ? Icons.help_outline_rounded : icon,
            size: 14,
            color: muted ? AppColors.gold : AppColors.muted,
          ),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.small.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _MiniInfoBadge extends StatelessWidget {
  const _MiniInfoBadge({required this.label, required this.positive});

  final String label;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final color = positive ? AppColors.success : AppColors.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            positive ? Icons.check_circle_rounded : Icons.remove_circle_outline,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.small.copyWith(color: color)),
        ],
      ),
    );
  }
}

/// 필드별 검증 근거(재검증 필요 여부 포함)를 나열하는 섹션.
class _FieldEvidenceSection extends StatelessWidget {
  const _FieldEvidenceSection({required this.evidence});

  final List<FieldEvidence> evidence;

  Color _colorOf(EvidenceStatus status) {
    switch (status) {
      case EvidenceStatus.verified:
        return AppColors.success;
      case EvidenceStatus.partiallyVerified:
        return AppColors.blue;
      case EvidenceStatus.verificationRequired:
        return AppColors.gold;
      case EvidenceStatus.unavailable:
      case EvidenceStatus.notApplicable:
        return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('필드별 검증 현황', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          for (final item in evidence)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.fact_check_outlined,
                      size: 16,
                      color: _colorOf(item.effectiveStatus),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.field,
                                  style: AppTextStyles.bodyStrong,
                                ),
                              ),
                              Text(
                                item.effectiveStatus.label,
                                style: AppTextStyles.small.copyWith(
                                  color: _colorOf(item.effectiveStatus),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          if (item.note.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.note,
                              style: AppTextStyles.small.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
