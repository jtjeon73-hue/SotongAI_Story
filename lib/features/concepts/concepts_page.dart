import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../core/constants/route_paths.dart';
import '../../core/storage/favorites_storage.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/content_card.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/favorite_button.dart';
import '../../shared/widgets/responsive_grid.dart';
import '../../shared/widgets/search_field.dart';

/// AI 핵심 개념 그리드 페이지.
class ConceptsPage extends StatefulWidget {
  const ConceptsPage({super.key});

  @override
  State<ConceptsPage> createState() => _ConceptsPageState();
}

class _ConceptsPageState extends State<ConceptsPage> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final concepts = AppScope.of(context).repository.concepts;
    final filtered = _query.isEmpty
        ? concepts
        : concepts
              .where(
                (c) =>
                    c.name.toLowerCase().contains(_query.toLowerCase()) ||
                    c.oneLiner.toLowerCase().contains(_query.toLowerCase()),
              )
              .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeader(
            title: 'AI 핵심 개념',
            description: '머신러닝, 딥러닝, LLM 등 AI를 이해하는 데 필요한 핵심 개념을 쉬운 비유로 설명합니다.',
            searchField: SearchField(
              controller: _controller,
              hintText: '개념 이름으로 검색 (예: 트랜스포머, RAG)',
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          if (filtered.isEmpty)
            const EmptyStateView(title: '조건에 맞는 개념이 없습니다')
          else
            ResponsiveGrid(
              childAspectRatio: 1.25,
              children: filtered
                  .map(
                    (concept) => ContentCard(
                      title: concept.name,
                      description: concept.oneLiner,
                      accentColor: AppColors.purple,
                      leadingIcon: Icons.psychology_rounded,
                      trailing: FavoriteButton(
                        category: FavoriteCategory.concepts,
                        id: concept.id,
                      ),
                      onTap: () =>
                          context.push(RoutePaths.conceptsDetailOf(concept.id)),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}
