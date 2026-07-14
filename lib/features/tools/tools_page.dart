import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../core/models/ai_tool.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/filter_chips.dart';
import '../../shared/widgets/responsive_grid.dart';
import '../../shared/widgets/search_field.dart';
import 'widgets/tool_card.dart';

/// AI 툴 탐색 페이지. 카테고리·무료 여부·한국어 지원 필터와 검색을 제공한다.
class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  final _controller = TextEditingController();
  String _query = '';
  String? _category;
  bool _freeOnly = false;
  bool _koreanOnly = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tools = AppScope.of(context).repository.tools;
    final categories = tools.map((t) => t.category).toSet().toList()..sort();

    final filtered = tools.where((tool) {
      if (_category != null && tool.category != _category) return false;
      if (_freeOnly && !tool.isFree) return false;
      if (_koreanOnly && !tool.koreanSupport) return false;
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return tool.name.toLowerCase().contains(q) ||
          tool.description.toLowerCase().contains(q);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeader(
            title: 'AI 툴 탐색',
            description: '목적과 조건에 맞는 AI 도구를 카테고리, 요금제, 한국어 지원 여부로 찾아보세요.',
            searchField: SearchField(
              controller: _controller,
              hintText: '도구 이름으로 검색 (예: 챗GPT, 미드저니)',
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('무료 이용 가능'),
                selected: _freeOnly,
                onSelected: (v) => setState(() => _freeOnly = v),
              ),
              FilterChip(
                label: const Text('한국어 지원'),
                selected: _koreanOnly,
                onSelected: (v) => setState(() => _koreanOnly = v),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilterChipsBar<String>(
            options: categories
                .map(
                  (c) =>
                      FilterChipOption(value: c, label: aiToolCategoryLabel(c)),
                )
                .toList(),
            selected: _category,
            onSelected: (value) => setState(() => _category = value),
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            const EmptyStateView(title: '조건에 맞는 도구가 없습니다')
          else
            ResponsiveGrid(
              childAspectRatio: 1.2,
              children: filtered
                  .map<Widget>((tool) => ToolCard(tool: tool))
                  .toList(),
            ),
        ],
      ),
    );
  }
}
