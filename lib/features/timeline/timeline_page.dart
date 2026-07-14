import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../core/constants/route_paths.dart';
import '../../core/models/timeline_entry.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/content_card.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/filter_chips.dart';
import '../../shared/widgets/favorite_button.dart';
import '../../shared/widgets/search_field.dart';
import '../../shared/widgets/status_chip.dart';
import '../../core/storage/favorites_storage.dart';

/// AI 역사 연대표 목록 페이지. 카테고리 필터와 검색을 제공한다.
class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _category;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = AppScope.of(context).repository;
    final all = repository.timeline;

    final categories = all.map((e) => e.category).toSet().toList()..sort();

    final filtered = all.where((entry) {
      if (_category != null && entry.category != _category) return false;
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return entry.title.toLowerCase().contains(q) ||
          entry.summary.toLowerCase().contains(q) ||
          entry.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeader(
            title: 'AI 역사 연대표',
            description: '1950년부터 현재까지 인공지능 역사의 주요 사건을 시간순으로 확인하세요.',
            searchField: SearchField(
              controller: _searchController,
              hintText: '사건, 키워드로 검색 (예: 알파고, 트랜스포머)',
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          FilterChipsBar<String>(
            options: categories
                .map(
                  (c) => FilterChipOption(
                    value: c,
                    label: timelineCategoryLabel(c),
                  ),
                )
                .toList(),
            selected: _category,
            onSelected: (value) => setState(() => _category = value),
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            const EmptyStateView(
              title: '조건에 맞는 사건이 없습니다',
              message: '검색어나 카테고리 필터를 조정해보세요.',
            )
          else
            ...filtered.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TimelineListItem(entry: entry),
              ),
            ),
        ],
      ),
    );
  }
}

class _TimelineListItem extends StatelessWidget {
  const _TimelineListItem({required this.entry});

  final TimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    return ContentCard(
      title: entry.title,
      subtitle: entry.dateText,
      description: entry.summary,
      tags: entry.tags,
      accentColor: AppColors.blue,
      leadingIcon: Icons.timeline_rounded,
      trailing: FavoriteButton(
        category: FavoriteCategory.timeline,
        id: entry.id,
      ),
      footer: Row(
        children: [
          StatusChip(status: entry.status),
          const SizedBox(width: 8),
          _ImportanceStars(importance: entry.importance),
        ],
      ),
      onTap: () => context.push(RoutePaths.timelineDetailOf(entry.id)),
    );
  }
}

class _ImportanceStars extends StatelessWidget {
  const _ImportanceStars({required this.importance});

  final int importance;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '중요도 $importance/5',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (i) {
          return Icon(
            i < importance ? Icons.star_rounded : Icons.star_border_rounded,
            size: 14,
            color: AppColors.gold,
          );
        }),
      ),
    );
  }
}
