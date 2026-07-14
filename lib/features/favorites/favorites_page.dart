import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../core/constants/route_paths.dart';
import '../../core/storage/favorites_storage.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/content_card.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/favorite_button.dart';

/// 즐겨찾기한 콘텐츠(연대표/AI 툴/워크플로/핵심 개념)를 모아보는 페이지.
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  FavoritesStorage? _storage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final storage = AppScope.of(context).favorites;
    if (_storage != storage) {
      _storage?.removeListener(_onChanged);
      _storage = storage;
      _storage!.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    _storage?.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final repository = AppScope.of(context).repository;
    final storage = AppScope.of(context).favorites;

    final timelineIds = storage.idsOf(FavoriteCategory.timeline).toSet();
    final toolIds = storage.idsOf(FavoriteCategory.tools).toSet();
    final workflowIds = storage.idsOf(FavoriteCategory.workflows).toSet();
    final conceptIds = storage.idsOf(FavoriteCategory.concepts).toSet();

    final timelineEntries = repository.timeline
        .where((t) => timelineIds.contains(t.id))
        .toList();
    final tools = repository.tools
        .where((t) => toolIds.contains(t.id))
        .toList();
    final workflows = repository.workflows
        .where((w) => workflowIds.contains(w.id))
        .toList();
    final concepts = repository.concepts
        .where((c) => conceptIds.contains(c.id))
        .toList();

    final isEmpty =
        timelineEntries.isEmpty &&
        tools.isEmpty &&
        workflows.isEmpty &&
        concepts.isEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppHeader(
            title: '내 즐겨찾기',
            description: '관심 있는 연대표 사건, AI 툴, 워크플로, 핵심 개념을 모아볼 수 있습니다.',
          ),
          if (isEmpty)
            const EmptyStateView(
              icon: Icons.favorite_border_rounded,
              title: '아직 즐겨찾기한 콘텐츠가 없습니다',
              message: '각 콘텐츠의 하트 아이콘을 눌러 즐겨찾기에 추가해보세요.',
            )
          else ...[
            if (timelineEntries.isNotEmpty)
              _section('연대표', FavoriteCategory.timeline, [
                for (final t in timelineEntries)
                  ContentCard(
                    title: t.title,
                    subtitle: t.dateText,
                    description: t.summary,
                    accentColor: AppColors.blue,
                    leadingIcon: Icons.timeline_rounded,
                    trailing: FavoriteButton(
                      category: FavoriteCategory.timeline,
                      id: t.id,
                    ),
                    onTap: () =>
                        context.push(RoutePaths.timelineDetailOf(t.id)),
                  ),
              ]),
            if (tools.isNotEmpty)
              _section('AI 툴', FavoriteCategory.tools, [
                for (final t in tools)
                  ContentCard(
                    title: t.name,
                    subtitle: t.company,
                    description: t.description,
                    accentColor: AppColors.teal,
                    leadingIcon: Icons.smart_toy_rounded,
                    trailing: FavoriteButton(
                      category: FavoriteCategory.tools,
                      id: t.id,
                    ),
                    onTap: () => context.push(RoutePaths.toolsDetailOf(t.id)),
                  ),
              ]),
            if (workflows.isNotEmpty)
              _section('워크플로', FavoriteCategory.workflows, [
                for (final w in workflows)
                  ContentCard(
                    title: w.title,
                    subtitle: w.summary,
                    accentColor: AppColors.gold,
                    leadingIcon: Icons.account_tree_rounded,
                    trailing: FavoriteButton(
                      category: FavoriteCategory.workflows,
                      id: w.id,
                    ),
                    onTap: () =>
                        context.push(RoutePaths.workflowsDetailOf(w.id)),
                  ),
              ]),
            if (concepts.isNotEmpty)
              _section('핵심 개념', FavoriteCategory.concepts, [
                for (final c in concepts)
                  ContentCard(
                    title: c.name,
                    subtitle: c.oneLiner,
                    accentColor: AppColors.purple,
                    leadingIcon: Icons.psychology_rounded,
                    trailing: FavoriteButton(
                      category: FavoriteCategory.concepts,
                      id: c.id,
                    ),
                    onTap: () =>
                        context.push(RoutePaths.conceptsDetailOf(c.id)),
                  ),
              ]),
          ],
        ],
      ),
    );
  }

  Widget _section(String title, FavoriteCategory category, List<Widget> cards) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h2),
          const SizedBox(height: 12),
          for (final card in cards)
            Padding(padding: const EdgeInsets.only(bottom: 10), child: card),
        ],
      ),
    );
  }
}
