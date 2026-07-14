import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../core/models/search_result.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/search_field.dart';

/// 통합 검색 결과 페이지. `?q=` 쿼리 파라미터로 검색어를 전달받는다.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialQuery,
  );
  late String _query = widget.initialQuery;

  @override
  void didUpdateWidget(covariant SearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialQuery != oldWidget.initialQuery) {
      _controller.text = widget.initialQuery;
      setState(() => _query = widget.initialQuery);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = AppScope.of(context).repository;
    final results = repository.search(_query);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeader(
            title: '통합 검색',
            description: '연대표, 시대, 핵심 개념, AI 툴, 활용사례, 워크플로, 용어사전을 한 번에 검색합니다.',
            searchField: SearchField(
              controller: _controller,
              hintText: '검색어를 입력하세요 (예: 챗GPT, 프롬프트, 알파고)',
              autofocus: true,
              onChanged: (value) {
                setState(() => _query = value);
                context.go('/search?q=${Uri.encodeQueryComponent(value)}');
              },
            ),
          ),
          if (_query.trim().isEmpty)
            const EmptyStateView(
              icon: Icons.search_rounded,
              title: '검색어를 입력해주세요',
              message: '궁금한 AI 개념이나 도구 이름을 입력해보세요.',
            )
          else if (results.isEmpty)
            EmptyStateView(
              icon: Icons.search_off_rounded,
              title: '"$_query"에 대한 검색 결과가 없습니다',
              message: '다른 검색어로 다시 시도해보세요.',
            )
          else ...[
            Text(
              '검색 결과 ${results.length}건',
              style: AppTextStyles.small.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 12),
            for (final result in results)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ResultRow(result: result),
              ),
          ],
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.result});

  final SearchResult result;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${result.type.label}: ${result.title}',
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.push(result.routePath),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    result.type.icon,
                    color: AppColors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.type.label,
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.blue,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(result.title, style: AppTextStyles.bodyStrong),
                      const SizedBox(height: 4),
                      Text(
                        result.snippet,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.muted,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
