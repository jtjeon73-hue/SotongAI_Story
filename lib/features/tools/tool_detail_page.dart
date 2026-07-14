import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/route_paths.dart';
import '../../core/models/ai_tool.dart';
import '../../core/services/link_service.dart';
import '../../core/storage/favorites_storage.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/favorite_button.dart';
import '../../shared/widgets/share_button.dart';
import '../../shared/widgets/source_list.dart';
import '../../shared/widgets/status_chip.dart';

/// AI 도구 상세 페이지.
class ToolDetailPage extends StatelessWidget {
  const ToolDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final repository = AppScope.of(context).repository;
    final tool = repository.toolById(id);

    if (tool == null) {
      return const EmptyStateView(
        icon: Icons.search_off_rounded,
        title: '도구를 찾을 수 없습니다',
      );
    }

    final shareUrl =
        '${AppConstants.firebaseHostingUrl}${RoutePaths.toolsDetailOf(tool.id)}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeader(
            title: tool.name,
            description: tool.description,
            verifiedAt: tool.lastVerified,
            actions: [
              FavoriteButton(category: FavoriteCategory.tools, id: tool.id),
              ShareButton(
                title: tool.name,
                url: shareUrl,
                text: tool.description,
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusChip(status: tool.status),
              _InfoChip(icon: Icons.apartment_rounded, label: tool.company),
              _InfoChip(
                icon: Icons.category_rounded,
                label: aiToolCategoryLabel(tool.category),
              ),
              _InfoChip(
                icon: Icons.payments_outlined,
                label: _pricingLabel(tool.pricingType),
              ),
              if (tool.koreanSupport)
                const _InfoChip(icon: Icons.translate_rounded, label: '한국어 지원'),
              if (tool.apiAvailable)
                const _InfoChip(icon: Icons.api_rounded, label: 'API 제공'),
              if (tool.localExecution)
                const _InfoChip(
                  icon: Icons.computer_rounded,
                  label: '로컬 실행 가능',
                ),
            ],
          ),
          const SizedBox(height: 20),
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
          _Section(title: '데이터 안전 참고', body: tool.dataSafetyNote),
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
          SourceList(sourceIds: tool.sourceIds, resolve: repository.sourceById),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _pricingLabel(String pricingType) {
    const map = {'free': '무료', 'freemium': '무료+유료 혼합', 'paid': '유료'};
    return map[pricingType] ?? pricingType;
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
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
