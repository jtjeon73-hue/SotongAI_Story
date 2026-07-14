import 'package:flutter/material.dart';

import '../../core/models/source.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'source_badge.dart';

/// 출처 ID 목록을 실제 [Source] 목록으로 변환해 배지 형태로 나열하는 위젯.
class SourceList extends StatelessWidget {
  const SourceList({
    super.key,
    required this.sourceIds,
    required this.resolve,
    this.label = '출처',
  });

  final List<String> sourceIds;
  final Source? Function(String id) resolve;
  final String label;

  @override
  Widget build(BuildContext context) {
    final sources = sourceIds.map(resolve).whereType<Source>().toList();
    if (sources.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.small.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: sources.map((s) => SourceBadge(source: s)).toList(),
        ),
      ],
    );
  }
}
