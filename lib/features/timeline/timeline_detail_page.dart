import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/route_paths.dart';
import '../../core/models/timeline_entry.dart';
import '../../core/repositories/content_repository.dart';
import '../../core/storage/favorites_storage.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/deferred_content.dart';
import '../../shared/widgets/detail_page_scaffold.dart';
import '../../shared/widgets/empty_state.dart';

/// 연대표 사건 상세 페이지.
class TimelineDetailPage extends StatelessWidget {
  const TimelineDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final repository = AppScope.of(context).repository;
    // 목록 페이지를 거치지 않고 상세 경로로 바로 진입(딥링크)하는 경우를
    // 대비해, 상세 페이지에서도 타임라인 로드를 직접 보장한다.
    return DeferredContent<void>(
      load: repository.ensureTimeline,
      loadingMessage: '사건 정보를 불러오는 중입니다...',
      builder: (context, _) => _buildContent(context, repository),
    );
  }

  Widget _buildContent(BuildContext context, ContentRepository repository) {
    final entry = repository.timelineById(id);

    if (entry == null) {
      return const EmptyStateView(
        icon: Icons.search_off_rounded,
        title: '사건을 찾을 수 없습니다',
        message: '삭제되었거나 잘못된 주소일 수 있습니다.',
      );
    }

    final era = repository.eraById(entry.era);
    final shareUrl =
        '${AppConstants.firebaseHostingUrl}${RoutePaths.timelineDetailOf(entry.id)}';

    return DetailPageScaffold(
      breadcrumb: [
        const DetailBreadcrumbItem(label: '홈', route: RoutePaths.home),
        const DetailBreadcrumbItem(label: 'AI 역사 연대표', route: RoutePaths.timeline),
        DetailBreadcrumbItem(label: entry.title),
      ],
      typeBadge: '연대표 사건',
      title: entry.title,
      summary: entry.summary,
      status: entry.status,
      verifiedAt: entry.verifiedAt,
      favoriteCategory: FavoriteCategory.timeline,
      favoriteId: entry.id,
      shareUrl: shareUrl,
      shareText: entry.summary,
      pageContext: 'AI 역사 연대표 상세: ${entry.title}',
      sourceIds: entry.sourceIds,
      resolveSource: repository.sourceById,
      infoChips: [
        _InfoChip(icon: Icons.event_rounded, label: entry.dateText),
        _InfoChip(
          icon: Icons.category_rounded,
          label: timelineCategoryLabel(entry.category),
        ),
        if (era != null)
          _InfoChip(
            icon: Icons.history_edu_rounded,
            label: era.title,
            onTap: () => context.push(RoutePaths.erasDetailOf(era.id)),
          ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Section(title: '자세히 보기', body: entry.details),
          _Section(title: '배경', body: entry.background),
          _Section(title: '왜 중요한가', body: entry.whyItMatters),
          _Section(title: '오늘날과의 연결', body: entry.currentConnection),
          if (entry.relatedPeople.isNotEmpty)
            _TagSection(
              title: '관련 인물',
              tags: entry.relatedPeople,
              icon: Icons.person_rounded,
            ),
          if (entry.relatedOrganizations.isNotEmpty)
            _TagSection(
              title: '관련 기관',
              tags: entry.relatedOrganizations,
              icon: Icons.apartment_rounded,
            ),
          if (entry.tags.isNotEmpty)
            _TagSection(title: '태그', tags: entry.tags, icon: Icons.tag_rounded),
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
          Text(body, style: AppTextStyles.body),
        ],
      ),
    );
  }
}

class _TagSection extends StatelessWidget {
  const _TagSection({
    required this.title,
    required this.tags,
    required this.icon,
  });

  final String title;
  final List<String> tags;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.small.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
                .map(
                  (tag) => Chip(
                    avatar: Icon(icon, size: 14, color: AppColors.muted),
                    label: Text(tag),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.muted),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.small.copyWith(color: AppColors.text),
            ),
          ],
        ),
      ),
    );
  }
}
