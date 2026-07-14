import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/route_paths.dart';
import '../../core/models/timeline_entry.dart';
import '../../core/repositories/content_repository.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/deferred_content.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/share_button.dart';
import '../../shared/widgets/source_list.dart';
import '../../shared/widgets/status_chip.dart';

/// 시대 상세 페이지.
class EraDetailPage extends StatelessWidget {
  const EraDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final repository = AppScope.of(context).repository;
    // "관련 연대표 사건" 섹션이 지연 로딩되는 타임라인 데이터를 참조하므로
    // 미리 로드를 보장한다(시대 자체 정보는 이미 부트스트랩에 포함되어 있음).
    return DeferredContent<void>(
      load: repository.ensureTimeline,
      loadingMessage: '시대 정보를 불러오는 중입니다...',
      builder: (context, _) => _buildContent(context, repository),
    );
  }

  Widget _buildContent(BuildContext context, ContentRepository repository) {
    final era = repository.eraById(id);

    if (era == null) {
      return const EmptyStateView(
        icon: Icons.search_off_rounded,
        title: '시대 정보를 찾을 수 없습니다',
      );
    }

    final relatedEvents = era.relatedTimelineIds
        .map(repository.timelineById)
        .whereType<TimelineEntry>()
        .toList();
    final shareUrl =
        '${AppConstants.firebaseHostingUrl}${RoutePaths.erasDetailOf(era.id)}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeader(
            title: era.title,
            description: era.period,
            verifiedAt: era.verifiedAt,
            actions: [
              ShareButton(
                title: era.title,
                url: shareUrl,
                text: era.keyQuestion,
              ),
            ],
          ),
          StatusChip(status: era.status),
          const SizedBox(height: 16),
          _Section(title: '핵심 질문', body: era.keyQuestion),
          _Section(
            title: '요약',
            body: era.summary3Lines.map((l) => '· $l').join('\n'),
          ),
          _Section(title: '기대와 전망', body: era.expectations),
          _Section(title: '한계', body: era.limitations),
          _Section(title: '전환점', body: era.transitionTrigger),
          _Section(title: '남긴 유산', body: era.lastingImpact),
          if (era.keyTechnologies.isNotEmpty)
            _ChipSection(title: '핵심 기술', items: era.keyTechnologies),
          if (era.keyPeople.isNotEmpty)
            _ChipSection(title: '핵심 인물', items: era.keyPeople),
          if (era.keyOrganizations.isNotEmpty)
            _ChipSection(title: '핵심 기관', items: era.keyOrganizations),
          if (relatedEvents.isNotEmpty) ...[
            Text('관련 연대표 사건', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            for (final event in relatedEvents)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.timeline_rounded,
                  color: AppColors.blue,
                ),
                title: Text(event.title),
                subtitle: Text(event.dateText),
                onTap: () =>
                    context.push(RoutePaths.timelineDetailOf(event.id)),
              ),
          ],
          const SizedBox(height: 12),
          SourceList(sourceIds: era.sourceIds, resolve: repository.sourceById),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    if (body.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text(body, style: AppTextStyles.body),
        ],
      ),
    );
  }
}

class _ChipSection extends StatelessWidget {
  const _ChipSection({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.small.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) => Chip(label: Text(item))).toList(),
          ),
        ],
      ),
    );
  }
}
