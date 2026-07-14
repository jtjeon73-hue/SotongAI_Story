import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/page_section_list.dart';

/// 산업별·농업 분야 AI 활용 사례를 소개하는 섹션 기반 페이지.
class IndustryAiPage extends StatelessWidget {
  const IndustryAiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AppScope.of(context).repository;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppHeader(
            title: '산업·농업 AI',
            description: '제조·유통·의료·금융·농업 등 다양한 산업 현장에서 AI가 어떻게 활용되고 있는지 소개합니다.',
          ),
          Text('산업별 활용', style: AppTextStyles.h2),
          const SizedBox(height: 12),
          PageSectionList(
            sections: repository.industrySections,
            repository: repository,
            accentColor: AppColors.teal,
            emptyMessage: '표시할 산업 정보가 없습니다',
          ),
          const SizedBox(height: 24),
          Text('농업 AI', style: AppTextStyles.h2),
          const SizedBox(height: 12),
          PageSectionList(
            sections: repository.agricultureSections,
            repository: repository,
            accentColor: AppColors.success,
            emptyMessage: '표시할 농업 정보가 없습니다',
          ),
        ],
      ),
    );
  }
}
