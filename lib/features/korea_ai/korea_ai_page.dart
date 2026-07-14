import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

import '../../app/app_scope.dart';
import '../../core/models/checklist_category.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/content_card.dart';
import '../../shared/widgets/page_section_list.dart';

/// 대한민국과 AI 정책·산업 흐름 + AI 도입 체크리스트 페이지.
class KoreaAiPage extends StatefulWidget {
  const KoreaAiPage({super.key});

  @override
  State<KoreaAiPage> createState() => _KoreaAiPageState();
}

class _KoreaAiPageState extends State<KoreaAiPage> {
  List<ChecklistCategory>? _checklists;
  Object? _checklistError;

  @override
  void initState() {
    super.initState();
    _loadChecklists();
  }

  Future<void> _loadChecklists() async {
    try {
      final raw =
          await rootBundle.loadString('assets/data/ai_adoption_checklists.json');
      final list = json.decode(raw) as List<dynamic>;
      final parsed = list
          .map((e) => ChecklistCategory.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      if (!mounted) return;
      setState(() {
        _checklists = parsed;
        _checklistError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _checklistError = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = AppScope.of(context).repository;
    final sections = repository.koreaAiSections;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppHeader(
            title: '대한민국과 AI',
            description:
                '한국 AI 정책·산업 흐름과 함께, 공공·기업·교육·산업 현장에서 AI를 도입하기 전 '
                '확인할 실무 체크리스트를 제공합니다. 정부 추천이나 공식 인증을 의미하지 않습니다.',
          ),
          PageSectionList(
            sections: sections,
            repository: repository,
            accentColor: AppColors.blue,
            emptyMessage: '표시할 정책 정보가 없습니다',
          ),
          const SizedBox(height: 28),
          Text('AI 도입 체크리스트', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text(
            '인쇄하거나 PDF로 저장해 내부 점검에 활용할 수 있습니다. '
            '법적·제도적 판단을 대체하지 않는 참고용 목록입니다.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 12),
          if (_checklistError != null)
            ContentCard(
              title: '체크리스트를 불러오지 못했습니다',
              description: '다시 시도하거나 나중에 확인해 주세요.',
              onTap: _loadChecklists,
            )
          else if (_checklists == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            ..._checklists!.map(_buildChecklist),
        ],
      ),
    );
  }

  Widget _buildChecklist(ChecklistCategory category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category.title, style: AppTextStyles.h3),
            const SizedBox(height: 6),
            Text(category.description, style: AppTextStyles.body),
            const SizedBox(height: 8),
            Text(category.disclaimer, style: AppTextStyles.caption),
            const SizedBox(height: 12),
            ...category.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_box_outline_blank,
                      size: 20,
                      color: AppColors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item.text, style: AppTextStyles.body),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
