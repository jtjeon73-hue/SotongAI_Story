import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_paths.dart';
import '../../../core/models/timeline_entry.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/content_card.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/verified_badge.dart';

/// 최근 검증된 연대표 콘텐츠 미리보기 섹션.
class HomeRecentVerified extends StatelessWidget {
  const HomeRecentVerified({super.key, required this.entries});

  final List<TimelineEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: '최근 검증된 콘텐츠',
          subtitle: '출처를 바탕으로 최근 검증을 마친 연대표 사건입니다.',
          action: TextButton(
            onPressed: () => context.push(RoutePaths.timeline),
            child: const Text('전체 보기'),
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: entries.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return SizedBox(
                width: 280,
                child: ContentCard(
                  title: entry.title,
                  subtitle: entry.dateText,
                  description: entry.summary,
                  accentColor: AppColors.blue,
                  leadingIcon: Icons.timeline_rounded,
                  footer: VerifiedBadge(verifiedAt: entry.verifiedAt),
                  onTap: () =>
                      context.push(RoutePaths.timelineDetailOf(entry.id)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
