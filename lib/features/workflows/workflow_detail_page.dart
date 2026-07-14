import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/route_paths.dart';
import '../../core/models/ai_tool.dart';
import '../../core/models/workflow.dart';
import '../../core/storage/favorites_storage.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/favorite_button.dart';
import '../../shared/widgets/share_button.dart';
import '../../shared/widgets/source_list.dart';
import '../tools/widgets/tool_card.dart';

/// 실전 AI 워크플로 상세 페이지. 단계별 실행 안내를 표시한다.
class WorkflowDetailPage extends StatelessWidget {
  const WorkflowDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final repository = AppScope.of(context).repository;
    final workflow = repository.workflowById(id);

    if (workflow == null) {
      return const EmptyStateView(
        icon: Icons.search_off_rounded,
        title: '워크플로를 찾을 수 없습니다',
      );
    }

    final recommendedTools = workflow.recommendedToolIds
        .map(repository.toolById)
        .whereType<AiTool>()
        .toList();
    final relatedTools = workflow.relatedToolIds
        .map(repository.toolById)
        .whereType<AiTool>()
        .toList();
    final shareUrl =
        '${AppConstants.firebaseHostingUrl}${RoutePaths.workflowsDetailOf(workflow.id)}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeader(
            title: workflow.title,
            description:
                '${difficultyLabel(workflow.difficulty)} · ${workflow.steps.length}단계 · ${workflow.estimatedTimeNote}',
            verifiedAt: workflow.verifiedAt,
            actions: [
              FavoriteButton(
                category: FavoriteCategory.workflows,
                id: workflow.id,
              ),
              ShareButton(title: workflow.title, url: shareUrl),
            ],
          ),
          _Section(title: '목표', body: workflow.objective),
          Text(workflow.summary, style: AppTextStyles.body),
          const SizedBox(height: 20),
          if (workflow.prerequisites.isNotEmpty)
            _BulletSection(
              title: '사전 준비물',
              items: workflow.prerequisites,
              icon: Icons.checklist_rounded,
            ),
          if (recommendedTools.isNotEmpty) ...[
            Text('추천 도구', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recommendedTools
                  .map(
                    (t) => ActionChip(
                      avatar: const Icon(Icons.smart_toy_rounded, size: 16),
                      label: Text(t.name),
                      onPressed: () =>
                          context.push(RoutePaths.toolsDetailOf(t.id)),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],
          Text('실행 단계', style: AppTextStyles.h2),
          const SizedBox(height: 12),
          for (final step in workflow.steps)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _StepCard(step: step),
            ),
          if (workflow.humanReviewPoints.isNotEmpty)
            _BulletSection(
              title: '사람이 반드시 확인할 점',
              items: workflow.humanReviewPoints,
              icon: Icons.fact_check_outlined,
              color: AppColors.gold,
            ),
          if (workflow.privacyWarnings.isNotEmpty)
            _BulletSection(
              title: '개인정보·보안 주의사항',
              items: workflow.privacyWarnings,
              icon: Icons.privacy_tip_outlined,
              color: AppColors.error,
            ),
          _Section(title: '기대 결과물', body: workflow.expectedOutput),
          if (relatedTools.isNotEmpty) ...[
            Text('관련 도구 더보기', style: AppTextStyles.h3),
            const SizedBox(height: 10),
            for (final tool in relatedTools)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ToolCard(tool: tool),
              ),
          ],
          SourceList(
            sourceIds: workflow.sourceIds,
            resolve: repository.sourceById,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.step});

  final WorkflowStep step;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.blue.withValues(alpha: 0.12),
                child: Text(
                  '${step.stepNumber}',
                  style: AppTextStyles.bodyStrong.copyWith(
                    color: AppColors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(step.action, style: AppTextStyles.bodyStrong),
              ),
            ],
          ),
          if (step.tools.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: step.tools
                  .map(
                    (t) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(t, style: AppTextStyles.small),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (step.inputExample.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              '입력 예시',
              style: AppTextStyles.small.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(step.inputExample, style: AppTextStyles.small),
            ),
          ],
          if (step.expectedResult.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              '예상 결과',
              style: AppTextStyles.small.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 4),
            Text(step.expectedResult, style: AppTextStyles.body),
          ],
          if (step.humanReviewPoints.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final point in step.humanReviewPoints)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.gold,
                  ),
                  const SizedBox(width: 6),
                  Expanded(child: Text(point, style: AppTextStyles.small)),
                ],
              ),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: 6),
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
    if (items.isEmpty) return const SizedBox.shrink();
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
