import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/ai_tool.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/empty_state.dart';

/// AI 툴 비교 페이지. 최대 3개 도구를 선택해 나란히 비교한다.
class ToolComparePage extends StatefulWidget {
  const ToolComparePage({super.key});

  @override
  State<ToolComparePage> createState() => _ToolComparePageState();
}

class _ToolComparePageState extends State<ToolComparePage> {
  final List<String> _selectedIds = [];

  void _toggle(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else if (_selectedIds.length < AppConstants.maxCompareTools) {
        _selectedIds.add(id);
      } else {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(
                '최대 ${AppConstants.maxCompareTools}개까지 비교할 수 있습니다.',
              ),
            ),
          );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tools = AppScope.of(context).repository.tools;
    final selectedTools = _selectedIds.map((id) {
      return tools.firstWhere((t) => t.id == id);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeader(
            title: 'AI 툴 비교',
            description:
                '최대 ${AppConstants.maxCompareTools}개의 AI 도구를 선택해 특징을 나란히 비교해보세요. '
                '목적에 따라 적합한 도구가 다르므로, 절대적인 우열보다는 상황에 맞는 선택을 돕기 위한 참고 자료입니다.',
          ),
          Text(
            '도구 선택 (최대 ${AppConstants.maxCompareTools}개)',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tools.map((tool) {
              final selected = _selectedIds.contains(tool.id);
              return FilterChip(
                label: Text(tool.name),
                selected: selected,
                onSelected: (_) => _toggle(tool.id),
                selectedColor: AppColors.blue.withValues(alpha: 0.12),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          if (selectedTools.isEmpty)
            const EmptyStateView(
              icon: Icons.compare_arrows_rounded,
              title: '비교할 도구를 선택해주세요',
              message: '위 목록에서 도구를 선택하면 비교표가 표시됩니다.',
            )
          else
            _CompareTable(tools: selectedTools),
        ],
      ),
    );
  }
}

class _CompareTable extends StatelessWidget {
  const _CompareTable({required this.tools});

  final List<AiTool> tools;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(8),
        ),
        defaultVerticalAlignment: TableCellVerticalAlignment.top,
        columnWidths: {
          0: const FixedColumnWidth(120),
          for (var i = 0; i < tools.length; i++)
            i + 1: const FixedColumnWidth(240),
        },
        children: [
          _row('항목', tools.map((t) => t.name).toList(), isHeader: true),
          _row('개발사', tools.map((t) => t.company).toList()),
          _row(
            '카테고리',
            tools.map((t) => aiToolCategoryLabel(t.category)).toList(),
          ),
          _row('요금제', tools.map((t) => t.pricingNote).toList()),
          _row(
            '한국어 지원',
            tools
                .map((t) => t.koreanSupport ? '지원' : '미지원(공식 사이트 확인 필요)')
                .toList(),
          ),
          _row(
            'API 제공',
            tools.map((t) => t.apiAvailable ? '제공' : '미제공').toList(),
          ),
          _row(
            '로컬 실행',
            tools.map((t) => t.localExecution ? '가능' : '불가').toList(),
          ),
          _row('주요 기능', tools.map((t) => t.keyFeatures.join(', ')).toList()),
          _row('강점', tools.map((t) => t.strengths.join(', ')).toList()),
          _row('한계', tools.map((t) => t.limitations.join(', ')).toList()),
          _row(
            '추천 활용',
            tools.map((t) => t.recommendedUseCases.join(', ')).toList(),
          ),
        ],
      ),
    );
  }

  TableRow _row(String label, List<String> values, {bool isHeader = false}) {
    return TableRow(
      decoration: BoxDecoration(color: isHeader ? AppColors.background : null),
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            label,
            style: isHeader
                ? AppTextStyles.bodyStrong
                : AppTextStyles.small.copyWith(color: AppColors.muted),
          ),
        ),
        for (final value in values)
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              value.isEmpty ? '-' : value,
              style: isHeader ? AppTextStyles.bodyStrong : AppTextStyles.body,
            ),
          ),
      ],
    );
  }
}
