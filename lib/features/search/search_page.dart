import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../core/constants/menu_items.dart';
import '../../core/constants/route_paths.dart';
import '../../core/models/content_status.dart';
import '../../core/models/search_result.dart';
import '../../core/storage/recent_search_storage.dart';
import '../../core/utils/search_utils.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/error_state.dart';
import '../../shared/widgets/filter_chips.dart';
import '../../shared/widgets/loading_view.dart';
import '../../shared/widgets/search_field.dart';
import '../../shared/widgets/status_chip.dart';

enum _SearchSort { relevance, recentVerified }

extension on _SearchSort {
  String get label => switch (this) {
    _SearchSort.relevance => '관련도순',
    _SearchSort.recentVerified => '최근 검증순',
  };
}

/// 통합 검색 결과 페이지. `?q=` `?type=` `?status=` 쿼리 파라미터로 검색어와
/// 필터를 전달받아 새로고침·링크 공유 시에도 동일한 결과를 재현한다.
///
/// 타임라인/도구/워크플로/용어사전은 지연 로딩되는 데이터이므로,
/// [ContentRepository.search]는 필요한 데이터를 먼저 로드한 뒤 검색하는
/// 비동기 메서드다. 이 페이지는 검색어가 바뀔 때마다 새 검색을 실행하고,
/// 결과 영역에만 로딩/에러 상태를 표시한다.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.initialParams = const {}});

  final Map<String, String> initialParams;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialParams['q'] ?? '',
  );
  late String _query = widget.initialParams['q'] ?? '';
  SearchResultType? _typeFilter;
  ContentStatus? _statusFilter;
  _SearchSort _sort = _SearchSort.relevance;
  Future<List<SearchResult>>? _future;
  bool _initialized = false;

  RecentSearchStorage? _recentStorage;
  List<String> _recentQueries = [];
  String _savedQuery = '';

  @override
  void initState() {
    super.initState();
    _typeFilter = _decodeType(widget.initialParams['type']);
    _statusFilter = _decodeStatus(widget.initialParams['status']);
    RecentSearchStorage.create().then((storage) {
      if (!mounted) return;
      setState(() {
        _recentStorage = storage;
        _recentQueries = storage.queries;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _runSearch();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  SearchResultType? _decodeType(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final t in SearchResultType.values) {
      if (t.name == raw) return t;
    }
    return null;
  }

  ContentStatus? _decodeStatus(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final s in ContentStatus.values) {
      if (s.name == raw) return s;
    }
    return null;
  }

  void _syncUrl() {
    final params = <String, String>{
      if (_query.trim().isNotEmpty) 'q': _query.trim(),
      if (_typeFilter != null) 'type': _typeFilter!.name,
      if (_statusFilter != null) 'status': _statusFilter!.name,
    };
    final path = params.isEmpty
        ? RoutePaths.search
        : Uri(path: RoutePaths.search, queryParameters: params).toString();
    context.go(path);
  }

  void _runSearch() {
    final repository = AppScope.of(context).repository;
    setState(() {
      _future = repository.search(_query);
    });
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _syncUrl();
    _runSearch();
  }

  void _saveToRecent(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty || trimmed == _savedQuery) return;
    _savedQuery = trimmed;
    _recentStorage?.add(trimmed).then((_) {
      if (!mounted) return;
      setState(() => _recentQueries = _recentStorage!.queries);
    });
  }

  void _selectRecentQuery(String query) {
    _controller.text = query;
    _onQueryChanged(query);
  }

  Future<void> _clearRecentQueries() async {
    await _recentStorage?.clear();
    if (!mounted) return;
    setState(() => _recentQueries = const []);
  }

  int _relevanceScore(SearchResult result, String query) {
    final q = normalizeSearchQuery(query);
    final title = normalizeSearchQuery(result.title);
    if (title == q) return 4;
    if (title.startsWith(q)) return 3;
    if (title.contains(q)) return 2;
    return 1;
  }

  List<SearchResult> _applyFiltersAndSort(List<SearchResult> results) {
    var filtered = results.where((r) {
      if (_typeFilter != null && r.type != _typeFilter) return false;
      if (_statusFilter != null && r.status != _statusFilter) return false;
      return true;
    }).toList();

    switch (_sort) {
      case _SearchSort.relevance:
        filtered.sort(
          (a, b) =>
              _relevanceScore(b, _query).compareTo(_relevanceScore(a, _query)),
        );
      case _SearchSort.recentVerified:
        filtered.sort((a, b) => b.verifiedAt.compareTo(a.verifiedAt));
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeader(
            title: '통합 검색',
            description: '연대표, 시대, 핵심 개념, AI 툴, 활용사례, 워크플로, 용어사전, 출처를 한 번에 검색합니다. '
                '초성만 입력해도(예: ㅊㅈㅍㅌ) 검색할 수 있습니다.',
            searchField: SearchField(
              controller: _controller,
              hintText: '검색어를 입력하세요 (예: 챗GPT, 프롬프트, 알파고)',
              autofocus: true,
              onChanged: _onQueryChanged,
              onSubmitted: _saveToRecent,
            ),
          ),
          if (_query.trim().isEmpty)
            _EmptySearchView(
              recentQueries: _recentQueries,
              onSelectRecent: _selectRecentQuery,
              onClearRecent: _clearRecentQueries,
            )
          else
            FutureBuilder<List<SearchResult>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const SizedBox(
                    height: 200,
                    child: LoadingView(message: '검색하는 중입니다...'),
                  );
                }
                if (snapshot.hasError) {
                  return ErrorStateView(
                    title: '검색 중 문제가 발생했습니다',
                    message: '${snapshot.error}',
                    onRetry: _runSearch,
                  );
                }
                final all = snapshot.data ?? const [];
                final results = _applyFiltersAndSort(all);
                final types = all.map((r) => r.type).toSet().toList()
                  ..sort((a, b) => a.label.compareTo(b.label));
                final statuses =
                    all
                        .map((r) => r.status)
                        .where((s) => s != ContentStatus.unknown)
                        .toSet()
                        .toList()
                      ..sort((a, b) => a.label.compareTo(b.label));

                if (all.isEmpty) {
                  return _NoResultsView(query: _query);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilterChipsBar<SearchResultType>(
                          options: types
                              .map(
                                (t) => FilterChipOption(
                                  value: t,
                                  label: '${t.label} (${all.where((r) => r.type == t).length})',
                                ),
                              )
                              .toList(),
                          selected: _typeFilter,
                          onSelected: (v) => setState(() => _typeFilter = v),
                          allLabel: '전체 유형',
                        ),
                      ],
                    ),
                    if (statuses.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilterChipsBar<ContentStatus>(
                            options: statuses
                                .map(
                                  (s) =>
                                      FilterChipOption(value: s, label: s.label),
                                )
                                .toList(),
                            selected: _statusFilter,
                            onSelected: (v) =>
                                setState(() => _statusFilter = v),
                            allLabel: '전체 상태',
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          '검색 결과 ${results.length}건',
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                        const Spacer(),
                        DropdownButton<_SearchSort>(
                          value: _sort,
                          underline: const SizedBox.shrink(),
                          items: _SearchSort.values
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text('정렬: ${s.label}'),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(
                            () => _sort = v ?? _SearchSort.relevance,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (results.isEmpty)
                      EmptyStateView(
                        icon: Icons.filter_alt_off_rounded,
                        title: '선택한 필터에 맞는 결과가 없습니다',
                        message: '유형이나 상태 필터를 조정해보세요.',
                        action: OutlinedButton(
                          onPressed: () => setState(() {
                            _typeFilter = null;
                            _statusFilter = null;
                          }),
                          child: const Text('필터 초기화'),
                        ),
                      )
                    else
                      for (final result in results)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ResultRow(result: result, query: _query),
                        ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _NoResultsView extends StatelessWidget {
  const _NoResultsView({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EmptyStateView(
          icon: Icons.search_off_rounded,
          title: '"$query"에 대한 검색 결과가 없습니다',
          message: '검색어를 줄이거나 다른 표현으로 다시 시도해보세요. 초성 검색(예: ㅊㅈㅍㅌ)도 지원합니다.',
        ),
        const SizedBox(height: 16),
        Text('대신 이런 메뉴는 어떠세요?', style: AppTextStyles.bodyStrong),
        const SizedBox(height: 10),
        const _RecommendedMenuGrid(),
      ],
    );
  }
}

class _EmptySearchView extends StatelessWidget {
  const _EmptySearchView({
    required this.recentQueries,
    required this.onSelectRecent,
    required this.onClearRecent,
  });

  final List<String> recentQueries;
  final ValueChanged<String> onSelectRecent;
  final VoidCallback onClearRecent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (recentQueries.isNotEmpty) ...[
          Row(
            children: [
              Text('최근 검색어', style: AppTextStyles.bodyStrong),
              const Spacer(),
              TextButton(
                onPressed: onClearRecent,
                child: const Text('전체 삭제'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recentQueries
                .map(
                  (q) => ActionChip(
                    avatar: const Icon(Icons.history_rounded, size: 16),
                    label: Text(q),
                    onPressed: () => onSelectRecent(q),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
        ],
        EmptyStateView(
          icon: Icons.search_rounded,
          title: '검색어를 입력해주세요',
          message: '궁금한 AI 개념이나 도구 이름을 입력해보세요. 초성만 입력해도 찾을 수 있습니다.',
        ),
        const SizedBox(height: 16),
        Text('추천 메뉴', style: AppTextStyles.bodyStrong),
        const SizedBox(height: 10),
        const _RecommendedMenuGrid(),
      ],
    );
  }
}

class _RecommendedMenuGrid extends StatelessWidget {
  const _RecommendedMenuGrid();

  static const _recommended = [
    MenuItems.tools,
    MenuItems.timeline,
    MenuItems.concepts,
    MenuItems.glossary,
    MenuItems.workflows,
    MenuItems.koreaAi,
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _recommended
          .map(
            (item) => Material(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => context.push(item.route),
                child: Container(
                  width: 180,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(item.icon, color: AppColors.blue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.result, required this.query});

  final SearchResult result;
  final String query;

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
                      Row(
                        children: [
                          Text(
                            result.type.label,
                            style: AppTextStyles.small.copyWith(
                              color: AppColors.blue,
                            ),
                          ),
                          if (result.status != ContentStatus.unknown) ...[
                            const SizedBox(width: 6),
                            StatusChip(status: result.status),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      highlightedText(
                        result.title,
                        query,
                        style: AppTextStyles.bodyStrong,
                      ),
                      const SizedBox(height: 4),
                      highlightedText(
                        result.snippet,
                        query,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.muted,
                        ),
                        maxLines: 2,
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

/// [query]와 일치하는 부분을 굵게/강조색으로 표시하는 텍스트 위젯을 만든다.
///
/// 대소문자·공백을 정규화해 위치를 찾은 뒤, 실제 표시는 원문 그대로 유지한다.
Widget highlightedText(
  String text,
  String query, {
  required TextStyle style,
  int? maxLines,
}) {
  final normalizedQuery = normalizeSearchQuery(query);
  if (normalizedQuery.isEmpty || isChosungOnlyQuery(normalizedQuery)) {
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
    );
  }

  final normalizedText = text.toLowerCase();
  final index = normalizedText.indexOf(normalizedQuery);
  if (index < 0) {
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
    );
  }

  final end = index + normalizedQuery.length;
  return Text.rich(
    TextSpan(
      children: [
        TextSpan(text: text.substring(0, index)),
        TextSpan(
          text: text.substring(index, end),
          style: TextStyle(
            color: AppColors.blue,
            fontWeight: FontWeight.w800,
            backgroundColor: AppColors.blue.withValues(alpha: 0.10),
          ),
        ),
        TextSpan(text: text.substring(end)),
      ],
    ),
    style: style,
    maxLines: maxLines,
    overflow: maxLines != null ? TextOverflow.ellipsis : null,
  );
}
