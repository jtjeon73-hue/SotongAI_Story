import 'package:flutter/material.dart';

import '../../core/models/page_section.dart';
import '../../core/models/source.dart';
import '../../core/repositories/content_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'empty_state.dart';
import 'source_list.dart';

/// 한국 AI/산업 AI/개발자 공간/안전·윤리 등 섹션 기반 페이지에서 공통으로
/// 쓰는 콘텐츠 블록 목록 위젯.
///
/// 각 섹션을 확장 가능한 카드로 표시하며, 본문·경고사항·코드 예시(있는 경우)·
/// 출처를 함께 보여준다.
class PageSectionList extends StatelessWidget {
  const PageSectionList({
    super.key,
    required this.sections,
    required this.repository,
    this.accentColor = AppColors.blue,
    this.emptyMessage = '표시할 내용이 없습니다',
  });

  final List<PageSection> sections;
  final ContentRepository repository;
  final Color accentColor;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return EmptyStateView(title: emptyMessage);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final section in sections)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SectionCard(
              section: section,
              accentColor: accentColor,
              resolveSource: repository.sourceById,
            ),
          ),
      ],
    );
  }
}

class _SectionCard extends StatefulWidget {
  const _SectionCard({
    required this.section,
    required this.accentColor,
    required this.resolveSource,
  });

  final PageSection section;
  final Color accentColor;
  final Source? Function(String id) resolveSource;

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final section = widget.section;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 24,
                    decoration: BoxDecoration(
                      color: widget.accentColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(section.title, style: AppTextStyles.h3),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: AppColors.muted,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (section.summary != null &&
                      section.summary!.isNotEmpty) ...[
                    Text(
                      section.summary!,
                      style: AppTextStyles.bodyStrong.copyWith(
                        color: widget.accentColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (section.displayBody.isNotEmpty)
                    Text(section.displayBody, style: AppTextStyles.body),
                  if (section.codeExample != null &&
                      section.codeExample!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.navy,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SelectableText(
                        section.codeExample!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'monospace',
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                  if (section.warnings.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    for (final warning in section.warnings)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              size: 16,
                              color: AppColors.gold,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                warning,
                                style: AppTextStyles.small.copyWith(
                                  color: AppColors.text,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  const SizedBox(height: 8),
                  SourceList(
                    sourceIds: section.sourceIds,
                    resolve: widget.resolveSource,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
