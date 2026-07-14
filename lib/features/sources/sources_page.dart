import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/search_result.dart';
import '../../core/models/site_updates.dart';
import '../../core/models/source.dart';
import '../../core/models/verification_stats.dart';
import '../../core/repositories/source_usage_lookup.dart';
import '../../core/services/link_service.dart';
import '../../core/utils/date_format_utils.dart';
import '../../core/utils/search_utils.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/deferred_content.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/filter_chips.dart';
import '../../shared/widgets/search_field.dart';

/// 출처·검증센터 페이지.
///
/// 사이트 전체 검증 현황([VerificationStats])을 요약하고, 모든 출처 목록을
/// 검색·유형별 필터·정렬 가능한 형태로 제공한다. 각 출처를 펼치면 해당
/// 출처를 인용하는 콘텐츠(역참조) 목록을 확인할 수 있다.
class SourcesPage extends StatefulWidget {
  const SourcesPage({super.key});

  @override
  State<SourcesPage> createState() => _SourcesPageState();
}

enum _SourceSort { recent, title, publisher, usage }

class _SourcesPageState extends State<SourcesPage> {
  final _controller = TextEditingController();
  String _query = '';
  String? _typeFilter;
  _SourceSort _sort = _SourceSort.recent;
  Future<Map<String, List<SearchResult>>>? _usageFuture;

  @override
  void initState() {
    super.initState();
    _loadUsage();
  }

  void _loadUsage() {
    final repository = AppScope.of(context).repository;
    _usageFuture = repository.allContentBySource();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = AppScope.of(context).repository;
    final updates = repository.siteUpdates;
    final types = repository.sources.map((s) => s.sourceType).toSet().toList()
      ..sort();

    var sources = repository.sources.where((s) {
      if (_typeFilter != null && s.sourceType != _typeFilter) return false;
      if (_query.isEmpty) return true;
      final q = normalizeSearchQuery(_query);
      return [
        s.title,
        s.publisher,
        s.note,
      ].any((f) => normalizeSearchQuery(f).contains(q));
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppHeader(
            title: '출처·검증센터',
            description:
                '소통AI스토리의 모든 콘텐츠는 공식 발표, 학술 자료, 언론 보도 등 확인 가능한 출처를 기반으로 작성됩니다. '
                '아래에서 사이트 전체 검증 현황과 개별 출처를 확인할 수 있습니다.',
          ),
          DeferredContent<VerificationStats>(
            load: repository.computeVerificationStats,
            loadingMessage: '검증 현황을 계산하는 중입니다...',
            builder: (context, stats) => _VerificationSummary(
              updates: updates,
              sourceCount: repository.sources.length,
              verificationStats: stats,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('전체 출처 목록', style: AppTextStyles.h2),
              const SizedBox(width: 8),
              Text(
                '${sources.length}건',
                style: AppTextStyles.small.copyWith(color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SearchField(
            controller: _controller,
            hintText: '출처 제목·발행처·비고 검색',
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChipsBar<String>(
                options: types
                    .map(
                      (t) =>
                          FilterChipOption(value: t, label: _sourceTypeLabel(t)),
                    )
                    .toList(),
                selected: _typeFilter,
                onSelected: (v) => setState(() => _typeFilter = v),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FutureBuilder<Map<String, List<SearchResult>>>(
              future: _usageFuture,
              builder: (context, snapshot) {
                final usage = snapshot.data ?? const {};
                sources = _applySort(sources, usage);
                return DropdownButton<_SourceSort>(
                  value: _sort,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(
                      value: _SourceSort.recent,
                      child: Text('정렬: 최신 발행일'),
                    ),
                    DropdownMenuItem(
                      value: _SourceSort.title,
                      child: Text('정렬: 제목순'),
                    ),
                    DropdownMenuItem(
                      value: _SourceSort.publisher,
                      child: Text('정렬: 발행처순'),
                    ),
                    DropdownMenuItem(
                      value: _SourceSort.usage,
                      child: Text('정렬: 인용 콘텐츠 많은 순'),
                    ),
                  ],
                  onChanged: (v) =>
                      setState(() => _sort = v ?? _SourceSort.recent),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          if (sources.isEmpty)
            EmptyStateView(
              title: '조건에 맞는 출처가 없습니다',
              message: _query.isEmpty && _typeFilter == null
                  ? null
                  : '검색어나 유형 필터를 조정해보세요.',
            )
          else
            FutureBuilder<Map<String, List<SearchResult>>>(
              future: _usageFuture,
              builder: (context, snapshot) {
                final usage = snapshot.data ?? const {};
                final sorted = _applySort(sources, usage);
                return Column(
                  children: [
                    for (final source in sorted)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _SourceRow(
                          source: source,
                          linkedContent: usage[source.id] ?? const [],
                        ),
                      ),
                  ],
                );
              },
            ),
          const SizedBox(height: 24),
          _ErrorReportCard(),
        ],
      ),
    );
  }

  List<Source> _applySort(
    List<Source> sources,
    Map<String, List<SearchResult>> usage,
  ) {
    final sorted = [...sources];
    switch (_sort) {
      case _SourceSort.recent:
        sorted.sort((a, b) => b.publishedDate.compareTo(a.publishedDate));
      case _SourceSort.title:
        sorted.sort((a, b) => a.title.compareTo(b.title));
      case _SourceSort.publisher:
        sorted.sort((a, b) => a.publisher.compareTo(b.publisher));
      case _SourceSort.usage:
        sorted.sort(
          (a, b) => (usage[b.id]?.length ?? 0).compareTo(
            usage[a.id]?.length ?? 0,
          ),
        );
    }
    return sorted;
  }
}

String _sourceTypeLabel(String type) {
  const map = {
    'official': '공식 자료',
    'news': '언론 보도',
    'academic': '학술 자료',
    'corporate': '기업 발표',
    'government': '정부 자료',
  };
  return map[type] ?? type;
}

class _VerificationSummary extends StatelessWidget {
  const _VerificationSummary({
    required this.updates,
    required this.sourceCount,
    required this.verificationStats,
  });

  final SiteUpdates updates;
  final int sourceCount;
  final VerificationStats verificationStats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 16,
        children: [
          _stat(
            '사이트 최종 업데이트',
            DateFormatUtils.formatKoreanDate(updates.siteLastUpdated),
          ),
          _stat(
            '콘텐츠 최종 검증',
            DateFormatUtils.formatKoreanDate(updates.contentLastVerified),
          ),
          _stat('버전', updates.version.isEmpty ? '-' : updates.version),
          _stat('전체 출처 수', '$sourceCount개'),
          _stat('전체 콘텐츠 항목', '${verificationStats.total}건'),
          _stat('검증 완료', '${verificationStats.verified}건'),
          _stat('부분 검증', '${verificationStats.partiallyVerified}건'),
          _stat('검증 필요', '${verificationStats.verificationRequired}건'),
          if (verificationStats.expired > 0)
            _stat('검증 만료', '${verificationStats.expired}건'),
          if (verificationStats.missingSources > 0)
            _stat('출처 미연결', '${verificationStats.missingSources}건'),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.small.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.h3),
        ],
      ),
    );
  }
}

class _SourceRow extends StatefulWidget {
  const _SourceRow({required this.source, required this.linkedContent});

  final Source source;
  final List<SearchResult> linkedContent;

  @override
  State<_SourceRow> createState() => _SourceRowState();
}

class _SourceRowState extends State<_SourceRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final source = widget.source;
    final linked = widget.linkedContent;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(source.title, style: AppTextStyles.bodyStrong),
                      const SizedBox(height: 4),
                      Text(
                        '${source.publisher} · ${_sourceTypeLabel(source.sourceType)}'
                        '${source.publishedDate.isEmpty ? '' : ' · ${DateFormatUtils.formatKoreanDate(source.publishedDate)}'}',
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                      if (source.note.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(source.note, style: AppTextStyles.body),
                      ],
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => setState(() => _expanded = !_expanded),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _expanded
                                  ? Icons.expand_less_rounded
                                  : Icons.expand_more_rounded,
                              size: 16,
                              color: AppColors.blue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '이 출처를 인용하는 콘텐츠 ${linked.length}건',
                              style: AppTextStyles.small.copyWith(
                                color: AppColors.blue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: '원문 열기',
                  child: IconButton(
                    onPressed: () => LinkService.openUrl(context, source.url),
                    icon: const Icon(
                      Icons.open_in_new_rounded,
                      color: AppColors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: linked.isEmpty
                  ? Text(
                      '이 출처를 인용하는 콘텐츠를 찾지 못했습니다.',
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.muted,
                      ),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: linked
                          .map(
                            (r) => ActionChip(
                              avatar: Icon(r.type.icon, size: 14),
                              label: Text('${r.type.label}: ${r.title}'),
                              onPressed: () => context.push(r.routePath),
                            ),
                          )
                          .toList(),
                    ),
            ),
        ],
      ),
    );
  }
}

class _ErrorReportCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '오류를 발견하셨나요?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '잘못된 정보나 오래된 내용을 발견하시면 알려주세요. 확인 후 신속히 반영하겠습니다.',
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => LinkService.openErrorReportEmail(
              context,
              pageContext: '출처·검증센터',
            ),
            icon: const Icon(Icons.mail_outline_rounded),
            label: Text('오류 제보하기 (${AppConstants.contactEmail})'),
          ),
        ],
      ),
    );
  }
}
