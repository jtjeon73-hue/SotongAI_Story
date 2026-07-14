import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/responsive_grid.dart';
import '../tools/widgets/tool_card.dart';

/// 숨은 보석 AI 도구 목록 페이지. 편집자 코멘트를 함께 보여준다.
class HiddenGemsPage extends StatelessWidget {
  const HiddenGemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = AppScope.of(context).repository.hiddenGemTools;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppHeader(
            title: '숨은 보석 AI',
            description: '아직 많이 알려지지 않았지만 특정 목적에 유용하게 쓸 수 있는 AI 도구를 소개합니다.',
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.purple.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.diamond_rounded, color: AppColors.purple),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '편집자 노트: 이 목록은 대중적 인기도보다 특정 상황에서의 실용성과 완성도를 기준으로 선정했습니다. '
                    '모든 도구가 모든 사람에게 최선은 아니므로, 본인의 목적에 맞는지 직접 확인해보세요.',
                    style: AppTextStyles.body.copyWith(color: AppColors.navy),
                  ),
                ),
              ],
            ),
          ),
          if (tools.isEmpty)
            const EmptyStateView(title: '표시할 숨은 보석 도구가 없습니다')
          else
            ResponsiveGrid(
              childAspectRatio: 1.2,
              children: tools
                  .map<Widget>((tool) => ToolCard(tool: tool))
                  .toList(),
            ),
        ],
      ),
    );
  }
}
