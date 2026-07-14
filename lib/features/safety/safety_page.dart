import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/page_section_list.dart';

/// AI 안전·윤리·저작권 관련 주제를 소개하는 섹션 기반 페이지.
class SafetyPage extends StatelessWidget {
  const SafetyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AppScope.of(context).repository;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppHeader(
            title: '안전·윤리·저작권',
            description:
                'AI 환각, 개인정보, 편향, 딥페이크, 저작권 등 AI를 안전하게 사용하기 위해 반드시 알아야 할 주제입니다.',
          ),
          PageSectionList(
            sections: repository.safetyTopics,
            repository: repository,
            accentColor: AppColors.error,
            emptyMessage: '표시할 안전 정보가 없습니다',
          ),
        ],
      ),
    );
  }
}
