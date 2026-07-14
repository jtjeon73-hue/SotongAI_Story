import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../core/constants/route_paths.dart';
import '../../core/models/workflow.dart';
import '../../core/storage/favorites_storage.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/content_card.dart';
import '../../shared/widgets/deferred_content.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/favorite_button.dart';
import '../../shared/widgets/filter_chips.dart';
import '../../shared/widgets/search_field.dart';

/// 실전 AI 워크플로 목록 페이지.
class WorkflowsPage extends StatefulWidget {
  const WorkflowsPage({super.key});

  @override
  State<WorkflowsPage> createState() => _WorkflowsPageState();
}

class _WorkflowsPageState extends State<WorkflowsPage> {
  final _controller = TextEditingController();
  String _query = '';
  String? _difficulty;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = AppScope.of(context).repository;
    return DeferredContent<void>(
      load: repository.ensureWorkflows,
      loadingMessage: '워크플로를 불러오는 중입니다...',
      builder: (context, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final workflows = AppScope.of(context).repository.workflows;
    final difficulties = workflows.map((w) => w.difficulty).toSet().toList();

    final filtered = workflows.where((w) {
      if (_difficulty != null && w.difficulty != _difficulty) return false;
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return w.title.toLowerCase().contains(q) ||
          w.summary.toLowerCase().contains(q);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeader(
            title: '실전 AI 워크플로',
            description: '실제 업무에 AI를 단계별로 적용하는 구체적인 워크플로를 안내합니다.',
            searchField: SearchField(
              controller: _controller,
              hintText: '워크플로 검색',
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          FilterChipsBar<String>(
            options: difficulties
                .map(
                  (d) => FilterChipOption(value: d, label: difficultyLabel(d)),
                )
                .toList(),
            selected: _difficulty,
            onSelected: (value) => setState(() => _difficulty = value),
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            const EmptyStateView(title: '조건에 맞는 워크플로가 없습니다')
          else
            for (final workflow in filtered)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _WorkflowCard(workflow: workflow),
              ),
        ],
      ),
    );
  }
}

class _WorkflowCard extends StatelessWidget {
  const _WorkflowCard({required this.workflow});

  final Workflow workflow;

  @override
  Widget build(BuildContext context) {
    return ContentCard(
      title: workflow.title,
      subtitle:
          '${difficultyLabel(workflow.difficulty)} · ${workflow.steps.length}단계',
      description: workflow.summary,
      accentColor: AppColors.gold,
      leadingIcon: Icons.account_tree_rounded,
      trailing: FavoriteButton(
        category: FavoriteCategory.workflows,
        id: workflow.id,
      ),
      footer: Text(
        workflow.estimatedTimeNote,
        style: const TextStyle(color: AppColors.muted, fontSize: 12),
      ),
      onTap: () => context.push(RoutePaths.workflowsDetailOf(workflow.id)),
    );
  }
}
