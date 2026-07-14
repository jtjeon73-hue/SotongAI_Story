import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../core/constants/route_paths.dart';
import '../../core/models/era.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/content_card.dart';
import '../../shared/widgets/empty_state.dart';

/// 시대별 AI 변천사 목록 페이지.
class ErasPage extends StatelessWidget {
  const ErasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final eras = AppScope.of(context).repository.eras;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppHeader(
            title: '시대별 AI 변천사',
            description: 'AI 발전을 여러 시대로 구분해 각 시기의 특징과 전환점을 살펴봅니다.',
          ),
          if (eras.isEmpty)
            const EmptyStateView(title: '표시할 시대 정보가 없습니다')
          else
            for (var i = 0; i < eras.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _EraTimelineCard(
                  era: eras[i],
                  index: i,
                  isLast: i == eras.length - 1,
                ),
              ),
        ],
      ),
    );
  }
}

class _EraTimelineCard extends StatelessWidget {
  const _EraTimelineCard({
    required this.era,
    required this.index,
    required this.isLast,
  });

  final Era era;
  final int index;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.accentCycle[index % AppColors.accentCycle.length];
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: AppColors.border)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ContentCard(
                title: era.title,
                subtitle: era.period,
                description: era.summary3Lines.join(' '),
                accentColor: color,
                leadingIcon: Icons.history_edu_rounded,
                footer: Text(
                  '핵심 질문: ${era.keyQuestion}',
                  style: AppTextStyles.caption.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
                onTap: () => context.push(RoutePaths.erasDetailOf(era.id)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
