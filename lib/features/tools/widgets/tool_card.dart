import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_paths.dart';
import '../../../core/models/ai_tool.dart';
import '../../../core/storage/favorites_storage.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/content_card.dart';
import '../../../shared/widgets/favorite_button.dart';

/// AI 도구 목록에서 공통으로 사용하는 카드.
class ToolCard extends StatelessWidget {
  const ToolCard({super.key, required this.tool});

  final AiTool tool;

  @override
  Widget build(BuildContext context) {
    return ContentCard(
      title: tool.name,
      subtitle: tool.company,
      description: tool.description,
      tags: [
        aiToolCategoryLabel(tool.category),
        if (tool.koreanSupportLevel.isSupportive) tool.koreanSupportLevel.label,
        if (tool.isFree) '무료 이용 가능',
      ],
      accentColor: AppColors.teal,
      leadingIcon: Icons.smart_toy_rounded,
      trailing: FavoriteButton(category: FavoriteCategory.tools, id: tool.id),
      footer: Row(
        children: [
          if (tool.isPopular)
            const _MiniBadge(label: '인기', color: AppColors.gold),
          if (tool.isHiddenGem)
            const _MiniBadge(label: '숨은 보석', color: AppColors.purple),
        ],
      ),
      onTap: () => context.push(RoutePaths.toolsDetailOf(tool.id)),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: AppTextStyles.small.copyWith(color: color)),
    );
  }
}
