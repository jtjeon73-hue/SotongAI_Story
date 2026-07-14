import 'package:flutter/material.dart';

import '../../../core/repositories/content_repository.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/responsive_grid.dart';

/// 저장소 통계를 기반으로 한 요약 카드 그리드.
class HomeStats extends StatelessWidget {
  const HomeStats({super.key, required this.stats});

  final ContentStats stats;

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem(
        '연대표 사건',
        stats.timelineCount,
        Icons.timeline_rounded,
        AppColors.blue,
      ),
      _StatItem(
        'AI 핵심 개념',
        stats.conceptCount,
        Icons.psychology_rounded,
        AppColors.purple,
      ),
      _StatItem(
        'AI 도구',
        stats.toolCount,
        Icons.smart_toy_rounded,
        AppColors.teal,
      ),
      _StatItem(
        '실전 워크플로',
        stats.workflowCount,
        Icons.account_tree_rounded,
        AppColors.gold,
      ),
      _StatItem(
        '활용사례',
        stats.useCaseCount,
        Icons.business_center_rounded,
        AppColors.blue,
      ),
      _StatItem(
        '용어사전',
        stats.glossaryCount,
        Icons.menu_book_rounded,
        AppColors.purple,
      ),
    ];

    return ResponsiveGrid(
      desktopColumns: 3,
      tabletColumns: 3,
      mobileColumns: 2,
      childAspectRatio: 1.6,
      children: items.map((item) => _StatCard(item: item)).toList(),
    );
  }
}

class _StatItem {
  const _StatItem(this.label, this.count, this.icon, this.color);

  final String label;
  final int count;
  final IconData icon;
  final Color color;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item});

  final _StatItem item;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${item.label} ${item.count}건',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: item.color, size: 22),
            const SizedBox(height: 8),
            Text(
              '${item.count}',
              style: AppTextStyles.h1.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: AppTextStyles.small.copyWith(color: AppColors.muted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
