import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/page_section_list.dart';

/// 대한민국과 AI 정책·산업 흐름을 소개하는 섹션 기반 페이지.
class KoreaAiPage extends StatelessWidget {
  const KoreaAiPage({super.key});

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
                '한국 정부의 AI 정책, 국내 기업의 초거대 AI 개발, 관련 법제화 흐름을 시간순으로 정리했습니다.',
          ),
          PageSectionList(
            sections: sections,
            repository: repository,
            accentColor: AppColors.blue,
            emptyMessage: '표시할 정책 정보가 없습니다',
          ),
        ],
      ),
    );
  }
}
