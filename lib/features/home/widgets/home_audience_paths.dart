import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_paths.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/responsive_grid.dart';
import '../../../shared/widgets/section_title.dart';

/// 이용자 유형별 추천 학습 경로 섹션.
class HomeAudiencePaths extends StatelessWidget {
  const HomeAudiencePaths({super.key});

  static const _paths = [
    _AudiencePath(
      title: 'AI를 처음 접하는 분',
      icon: Icons.eco_rounded,
      color: AppColors.teal,
      steps: ['AI 핵심 개념', 'AI 용어사전', 'AI 역사 연대표'],
      routes: [RoutePaths.concepts, RoutePaths.glossary, RoutePaths.timeline],
    ),
    _AudiencePath(
      title: '업무에 AI를 활용하려는 직장인',
      icon: Icons.work_rounded,
      color: AppColors.blue,
      steps: ['분야별 AI 활용', '실전 AI 워크플로', 'AI 툴 비교'],
      routes: [
        RoutePaths.useCases,
        RoutePaths.workflows,
        RoutePaths.toolCompare,
      ],
    ),
    _AudiencePath(
      title: '개발자·엔지니어',
      icon: Icons.code_rounded,
      color: AppColors.purple,
      steps: ['AI 개발자 공간', 'AI 툴 탐색', 'AI 핵심 개념'],
      routes: [RoutePaths.developer, RoutePaths.tools, RoutePaths.concepts],
    ),
    _AudiencePath(
      title: '정책·안전에 관심 있는 분',
      icon: Icons.shield_rounded,
      color: AppColors.gold,
      steps: ['대한민국과 AI', '안전·윤리·저작권', 'AI 미래 전망'],
      routes: [RoutePaths.koreaAi, RoutePaths.safety, RoutePaths.future],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: '나에게 맞는 학습 경로',
          subtitle: '이용자 유형에 따라 추천하는 콘텐츠 순서입니다.',
        ),
        ResponsiveGrid(
          desktopColumns: 2,
          tabletColumns: 2,
          mobileColumns: 1,
          childAspectRatio: 1.6,
          children: _paths.map((p) => _AudienceCard(path: p)).toList(),
        ),
      ],
    );
  }
}

class _AudiencePath {
  const _AudiencePath({
    required this.title,
    required this.icon,
    required this.color,
    required this.steps,
    required this.routes,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<String> steps;
  final List<String> routes;
}

class _AudienceCard extends StatelessWidget {
  const _AudienceCard({required this.path});

  final _AudiencePath path;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(path.icon, color: path.color, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(path.title, style: AppTextStyles.h3)),
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < path.steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Semantics(
                button: true,
                label: path.steps[i],
                child: InkWell(
                  onTap: () => context.push(path.routes[i]),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: path.color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${i + 1}',
                          style: AppTextStyles.small.copyWith(
                            color: path.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          path.steps[i],
                          style: AppTextStyles.body,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: AppColors.muted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
