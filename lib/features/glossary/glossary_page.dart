import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../core/models/glossary_entry.dart';
import '../../core/repositories/content_repository.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/deferred_content.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/filter_chips.dart';
import '../../shared/widgets/search_field.dart';
import '../../shared/widgets/source_list.dart';

enum _SortMode { korean, english }

/// AI 용어사전 페이지. 한글/영문 정렬, 카테고리 필터, 검색을 제공한다.
class GlossaryPage extends StatefulWidget {
  const GlossaryPage({super.key});

  @override
  State<GlossaryPage> createState() => _GlossaryPageState();
}

class _GlossaryPageState extends State<GlossaryPage> {
  final _controller = TextEditingController();
  String _query = '';
  String? _category;
  _SortMode _sortMode = _SortMode.korean;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = AppScope.of(context).repository;
    return DeferredContent<void>(
      load: repository.ensureGlossary,
      loadingMessage: '용어사전을 불러오는 중입니다...',
      builder: (context, _) => _buildContent(context, repository),
    );
  }

  Widget _buildContent(BuildContext context, ContentRepository repository) {
    final all = repository.glossary;
    final categories = all.map((e) => e.category).toSet().toList()..sort();

    var filtered = all.where((entry) {
      if (_category != null && entry.category != _category) return false;
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return entry.koreanTerm.toLowerCase().contains(q) ||
          entry.englishTerm.toLowerCase().contains(q) ||
          entry.shortDescription.toLowerCase().contains(q);
    }).toList();

    filtered.sort(
      (a, b) => _sortMode == _SortMode.korean
          ? a.koreanTerm.compareTo(b.koreanTerm)
          : a.englishTerm.toLowerCase().compareTo(b.englishTerm.toLowerCase()),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeader(
            title: 'AI 용어사전',
            description: 'AI 관련 용어를 한글·영문으로 찾아보고 뜻과 예시를 확인하세요.',
            searchField: SearchField(
              controller: _controller,
              hintText: '용어 검색 (예: 토큰, RAG)',
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Row(
            children: [
              const Text('정렬: '),
              const SizedBox(width: 4),
              ChoiceChip(
                label: const Text('가나다순'),
                selected: _sortMode == _SortMode.korean,
                onSelected: (_) => setState(() => _sortMode = _SortMode.korean),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('알파벳순'),
                selected: _sortMode == _SortMode.english,
                onSelected: (_) =>
                    setState(() => _sortMode = _SortMode.english),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilterChipsBar<String>(
            options: categories
                .map((c) => FilterChipOption(value: c, label: c))
                .toList(),
            selected: _category,
            onSelected: (value) => setState(() => _category = value),
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            const EmptyStateView(title: '조건에 맞는 용어가 없습니다')
          else
            for (final entry in filtered)
              _GlossaryTile(entry: entry, repository: repository),
        ],
      ),
    );
  }
}

class _GlossaryTile extends StatelessWidget {
  const _GlossaryTile({required this.entry, required this.repository});

  final GlossaryEntry entry;
  final ContentRepository repository;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: entry.koreanTerm,
                      style: AppTextStyles.bodyStrong,
                    ),
                    TextSpan(
                      text: '  (${entry.englishTerm})',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          entry.shortDescription,
          style: AppTextStyles.caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(entry.category, style: AppTextStyles.small),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '기술적 설명',
            style: AppTextStyles.small.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 4),
          Text(entry.technicalDescription, style: AppTextStyles.body),
          const SizedBox(height: 10),
          Text(
            '예시',
            style: AppTextStyles.small.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 4),
          Text(entry.example, style: AppTextStyles.body),
          if (entry.relatedTerms.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: entry.relatedTerms
                  .map((t) => Chip(label: Text(t)))
                  .toList(),
            ),
          ],
          const SizedBox(height: 10),
          SourceList(
            sourceIds: entry.sourceIds,
            resolve: repository.sourceById,
          ),
        ],
      ),
    );
  }
}
