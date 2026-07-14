import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/route_paths.dart';
import '../../core/models/ai_tool.dart';
import '../../core/models/use_case.dart';
import '../../core/models/workflow.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/share_button.dart';
import '../../shared/widgets/source_list.dart';
import '../tools/widgets/tool_card.dart';

/// 분야별 활용사례 상세 페이지.
class UseCaseDetailPage extends StatelessWidget {
  const UseCaseDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final repository = AppScope.of(context).repository;
    final useCase = repository.useCaseById(id);

    if (useCase == null) {
      return const EmptyStateView(
        icon: Icons.search_off_rounded,
        title: '활용사례를 찾을 수 없습니다',
      );
    }

    final tools = useCase.recommendedToolIds
        .map(repository.toolById)
        .whereType<AiTool>()
        .toList();
    final workflows = useCase.relatedWorkflowIds
        .map(repository.workflowById)
        .whereType<Workflow>()
        .toList();
    final shareUrl =
        '${AppConstants.firebaseHostingUrl}${RoutePaths.useCasesDetailOf(useCase.id)}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeader(
            title: useCase.title,
            description: useCaseCategoryLabel(useCase.category),
            verifiedAt: useCase.verifiedAt,
            actions: [ShareButton(title: useCase.title, url: shareUrl)],
          ),
          _BulletSection(
            title: '해결하는 문제',
            items: useCase.problemsSolved,
            icon: Icons.report_problem_outlined,
            color: AppColors.error,
          ),
          _BulletSection(
            title: '이용 절차',
            items: useCase.usageSteps,
            icon: Icons.arrow_forward_rounded,
            color: AppColors.blue,
            numbered: true,
          ),
          _BulletSection(
            title: '기대 효과',
            items: useCase.expectedBenefits,
            icon: Icons.trending_up_rounded,
            color: AppColors.success,
          ),
          _Section(title: '비용 참고', body: useCase.costNotes),
          _Section(title: '개인정보 주의사항', body: useCase.privacyNotes),
          _BulletSection(
            title: '사람이 반드시 확인할 점',
            items: useCase.humanCheckPoints,
            icon: Icons.fact_check_outlined,
            color: AppColors.gold,
          ),
          _Section(title: '시작하는 법', body: useCase.gettingStarted),
          if (tools.isNotEmpty) ...[
            Text('추천 도구', style: AppTextStyles.h3),
            const SizedBox(height: 10),
            for (final tool in tools)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ToolCard(tool: tool),
              ),
          ],
          if (workflows.isNotEmpty) ...[
            Text('관련 워크플로', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: workflows
                  .map(
                    (w) => ActionChip(
                      label: Text(w.title),
                      onPressed: () =>
                          context.push(RoutePaths.workflowsDetailOf(w.id)),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],
          SourceList(
            sourceIds: useCase.sourceIds,
            resolve: repository.sourceById,
          ),
          const SizedBox(height: 20),
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
    this.numbered = false,
  });

  final String title;
  final List<String> items;
  final IconData icon;
  final Color color;
  final bool numbered;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: 8),
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  numbered
                      ? CircleAvatar(
                          radius: 10,
                          backgroundColor: color.withValues(alpha: 0.15),
                          child: Text(
                            '${i + 1}',
                            style: AppTextStyles.small.copyWith(color: color),
                          ),
                        )
                      : Icon(icon, size: 18, color: color),
                  const SizedBox(width: 8),
                  Expanded(child: Text(items[i], style: AppTextStyles.body)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
