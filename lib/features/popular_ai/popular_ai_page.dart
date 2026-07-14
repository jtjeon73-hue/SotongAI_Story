import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/deferred_content.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/responsive_grid.dart';
import '../tools/widgets/tool_card.dart';

/// 인기·주목 AI 도구 목록 페이지.
class PopularAiPage extends StatelessWidget {
  const PopularAiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AppScope.of(context).repository;
    return DeferredContent<void>(
      load: repository.ensureTools,
      loadingMessage: 'AI 도구를 불러오는 중입니다...',
      builder: (context, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final tools = AppScope.of(context).repository.popularTools;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppHeader(
            title: '인기·주목 AI',
            description: '현재 가장 널리 쓰이고 주목받는 AI 도구를 모았습니다.',
          ),
          if (tools.isEmpty)
            const EmptyStateView(title: '표시할 인기 도구가 없습니다')
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
