import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/responsive_grid.dart';
import '../../../shared/widgets/section_title.dart';

/// AI 발전 단계를 시각적으로 요약하는 카드 섹션.
class HomeStages extends StatelessWidget {
  const HomeStages({super.key});

  static const _stages = [
    _StageItem(
      order: 1,
      title: '규칙 기반 AI',
      period: '1950년대~1980년대',
      description: '사람이 정한 규칙과 논리로 동작하는 초기 AI. 퍼셉트론, 전문가 시스템이 대표적입니다.',
      color: AppColors.blue,
    ),
    _StageItem(
      order: 2,
      title: '머신러닝의 부상',
      period: '1990년대~2000년대',
      description: '데이터로부터 패턴을 스스로 학습하는 통계 기반 접근이 확산되었습니다.',
      color: AppColors.teal,
    ),
    _StageItem(
      order: 3,
      title: '딥러닝 혁명',
      period: '2012년~2016년',
      description: 'AlexNet, 알파고 등 다층 신경망이 압도적 성능을 보이며 딥러닝이 주류가 되었습니다.',
      color: AppColors.purple,
    ),
    _StageItem(
      order: 4,
      title: '생성형 AI 대중화',
      period: '2022년~현재',
      description: '챗GPT 이후 누구나 사용할 수 있는 생성형 AI가 일상 도구로 자리잡았습니다.',
      color: AppColors.gold,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: 'AI 발전 4단계',
          subtitle: '규칙 기반에서 생성형 AI까지, 큰 흐름을 한눈에 확인하세요.',
        ),
        ResponsiveGrid(
          desktopColumns: 4,
          tabletColumns: 2,
          mobileColumns: 1,
          childAspectRatio: 1.05,
          children: _stages.map((stage) => _StageCard(stage: stage)).toList(),
        ),
      ],
    );
  }
}

class _StageItem {
  const _StageItem({
    required this.order,
    required this.title,
    required this.period,
    required this.description,
    required this.color,
  });

  final int order;
  final String title;
  final String period;
  final String description;
  final Color color;
}

class _StageCard extends StatelessWidget {
  const _StageCard({required this.stage});

  final _StageItem stage;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${stage.order}단계 ${stage.title}, ${stage.period}',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: stage.color,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${stage.order}',
                style: AppTextStyles.bodyStrong.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Text(stage.title, style: AppTextStyles.h3),
            const SizedBox(height: 2),
            Text(
              stage.period,
              style: AppTextStyles.small.copyWith(color: stage.color),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                stage.description,
                style: AppTextStyles.caption,
                overflow: TextOverflow.fade,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
