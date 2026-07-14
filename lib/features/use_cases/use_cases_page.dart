import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../core/constants/route_paths.dart';
import '../../core/models/use_case.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/content_card.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/filter_chips.dart';
import '../../shared/widgets/search_field.dart';

/// 분야별 AI 활용사례 목록 페이지.
class UseCasesPage extends StatefulWidget {
  const UseCasesPage({super.key});

  @override
  State<UseCasesPage> createState() => _UseCasesPageState();
}

class _UseCasesPageState extends State<UseCasesPage> {
  final _controller = TextEditingController();
  String _query = '';
  String? _category;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final useCases = AppScope.of(context).repository.useCases;
    final categories = useCases.map((u) => u.category).toSet().toList()..sort();

    final filtered = useCases.where((u) {
      if (_category != null && u.category != _category) return false;
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return u.title.toLowerCase().contains(q);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeader(
            title: '분야별 AI 활용',
            description: '업종·직무별로 AI를 실제로 활용하는 구체적인 사례를 소개합니다.',
            searchField: SearchField(
              controller: _controller,
              hintText: '업종·사례 검색',
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          FilterChipsBar<String>(
            options: categories
                .map(
                  (c) => FilterChipOption(
                    value: c,
                    label: useCaseCategoryLabel(c),
                  ),
                )
                .toList(),
            selected: _category,
            onSelected: (value) => setState(() => _category = value),
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            const EmptyStateView(title: '조건에 맞는 활용사례가 없습니다')
          else
            for (final useCase in filtered)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _UseCaseCard(useCase: useCase),
              ),
        ],
      ),
    );
  }
}

class _UseCaseCard extends StatelessWidget {
  const _UseCaseCard({required this.useCase});

  final UseCase useCase;

  @override
  Widget build(BuildContext context) {
    return ContentCard(
      title: useCase.title,
      subtitle: useCaseCategoryLabel(useCase.category),
      description: useCase.expectedBenefits.join(' · '),
      accentColor: AppColors.blue,
      leadingIcon: Icons.business_center_rounded,
      footer: Text(
        '난이도: ${_difficultyLabel(useCase.difficulty)}',
        style: const TextStyle(color: AppColors.muted, fontSize: 12),
      ),
      onTap: () => context.push(RoutePaths.useCasesDetailOf(useCase.id)),
    );
  }

  String _difficultyLabel(String difficulty) {
    const map = {'beginner': '초급', 'intermediate': '중급', 'advanced': '고급'};
    return map[difficulty] ?? difficulty;
  }
}
