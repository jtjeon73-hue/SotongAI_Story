import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/page_section_list.dart';

/// 개발자를 위한 AI API·프롬프트 엔지니어링·RAG 등 실전 주제 페이지.
class DeveloperPage extends StatelessWidget {
  const DeveloperPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AppScope.of(context).repository;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppHeader(
            title: 'AI 개발자 공간',
            description:
                'LLM API 연동, 프롬프트 엔지니어링, RAG, 로컬 모델 실행 등 개발자를 위한 실전 주제를 정리했습니다.',
          ),
          PageSectionList(
            sections: repository.developerTopics,
            repository: repository,
            accentColor: AppColors.purple,
            emptyMessage: '표시할 개발 주제가 없습니다',
          ),
        ],
      ),
    );
  }
}
