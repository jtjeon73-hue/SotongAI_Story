import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/route_paths.dart';
import '../../core/models/concept.dart';
import '../../core/storage/favorites_storage.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/favorite_button.dart';
import '../../shared/widgets/share_button.dart';
import '../../shared/widgets/source_list.dart';

/// AI 핵심 개념 상세 페이지.
class ConceptDetailPage extends StatelessWidget {
  const ConceptDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final repository = AppScope.of(context).repository;
    final concept = repository.conceptById(id);

    if (concept == null) {
      return const EmptyStateView(
        icon: Icons.search_off_rounded,
        title: '개념을 찾을 수 없습니다',
      );
    }

    final related = concept.relatedConceptIds
        .map(repository.conceptById)
        .whereType<Concept>()
        .toList();
    final shareUrl =
        '${AppConstants.firebaseHostingUrl}${RoutePaths.conceptsDetailOf(concept.id)}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeader(
            title: concept.name,
            description: concept.oneLiner,
            verifiedAt: concept.verifiedAt,
            actions: [
              FavoriteButton(
                category: FavoriteCategory.concepts,
                id: concept.id,
              ),
              ShareButton(
                title: concept.name,
                url: shareUrl,
                text: concept.oneLiner,
              ),
            ],
          ),
          _AnalogyBox(analogy: concept.analogy),
          const SizedBox(height: 20),
          _Section(title: '자세한 설명', body: concept.details),
          if (concept.useCases.isNotEmpty)
            _BulletSection(
              title: '활용 사례',
              items: concept.useCases,
              icon: Icons.check_circle_outline,
            ),
          if (concept.pros.isNotEmpty)
            _BulletSection(
              title: '장점',
              items: concept.pros,
              icon: Icons.thumb_up_outlined,
              color: AppColors.success,
            ),
          if (concept.cons.isNotEmpty)
            _BulletSection(
              title: '단점·한계',
              items: concept.cons,
              icon: Icons.thumb_down_outlined,
              color: AppColors.error,
            ),
          if (concept.commonMisconceptions.isNotEmpty)
            _BulletSection(
              title: '흔한 오해',
              items: concept.commonMisconceptions,
              icon: Icons.warning_amber_rounded,
              color: AppColors.gold,
            ),
          if (related.isNotEmpty) ...[
            Text('관련 개념', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: related
                  .map(
                    (r) => ActionChip(
                      label: Text(r.name),
                      onPressed: () =>
                          context.push(RoutePaths.conceptsDetailOf(r.id)),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],
          SourceList(
            sourceIds: concept.sourceIds,
            resolve: repository.sourceById,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _AnalogyBox extends StatelessWidget {
  const _AnalogyBox({required this.analogy});

  final String analogy;

  @override
  Widget build(BuildContext context) {
    if (analogy.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline_rounded, color: AppColors.teal),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              analogy,
              style: AppTextStyles.body.copyWith(color: AppColors.navy),
            ),
          ),
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
