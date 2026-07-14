import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/content_status.dart';
import '../../core/models/source.dart';
import '../../core/services/link_service.dart';
import '../../core/storage/favorites_storage.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_header.dart';
import 'favorite_button.dart';
import 'share_button.dart';
import 'source_list.dart';
import 'status_chip.dart';

/// [DetailPageScaffold] 상단 경로 표시줄의 항목 하나.
///
/// [route]가 있으면 탭해서 이동할 수 있는 링크로, 없으면(보통 마지막 항목,
/// 즉 현재 페이지) 굵게 강조된 일반 텍스트로 표시된다.
class DetailBreadcrumbItem {
  const DetailBreadcrumbItem({required this.label, this.route});

  final String label;
  final String? route;
}

/// 연대표/AI 툴/시대/핵심 개념 등 모든 상세 페이지가 공유하는 공통 뼈대.
///
/// 경로 표시줄, 콘텐츠 유형 배지, 제목·요약, 검증 상태·검증일, 즐겨찾기·
/// 공유 버튼, (선택) 정보 칩, 본문 슬롯, (선택) 관련 콘텐츠, 출처 목록
/// (연결 건수 포함), 오류 제보 버튼을 이 순서로 배치한다. 각 상세 페이지는
/// 유형별로 다른 [body]와 [infoChips]만 채워 넣으면 된다.
class DetailPageScaffold extends StatelessWidget {
  const DetailPageScaffold({
    super.key,
    required this.breadcrumb,
    required this.typeBadge,
    required this.title,
    this.summary,
    required this.status,
    required this.verifiedAt,
    required this.favoriteCategory,
    required this.favoriteId,
    required this.shareUrl,
    this.shareText,
    this.infoChips = const [],
    required this.body,
    this.related,
    required this.sourceIds,
    required this.resolveSource,
    this.pageContext,
  });

  /// 상단 경로 표시줄(예: 홈 > AI 툴 탐색 > 챗GPT).
  final List<DetailBreadcrumbItem> breadcrumb;

  /// 콘텐츠 유형 배지 라벨(예: "AI 툴", "연대표 사건").
  final String typeBadge;

  final String title;
  final String? summary;
  final ContentStatus status;

  /// `yyyy-MM-dd` 형식의 검증일. 비어있으면 [AppHeader]가 "검증일 미확인"으로
  /// 표시한다.
  final String verifiedAt;

  final FavoriteCategory favoriteCategory;
  final String favoriteId;

  final String shareUrl;
  final String? shareText;

  /// 유형별 추가 정보 칩(요금제, 카테고리, 연관 시대 등). 상태 배지 아래에
  /// 이어서 표시된다.
  final List<Widget> infoChips;

  /// 유형별 본문(섹션들). 페이지마다 자유롭게 구성한다.
  final Widget body;

  /// 관련 콘텐츠 섹션(선택).
  final Widget? related;

  final List<String> sourceIds;
  final Source? Function(String id) resolveSource;

  /// 오류 제보 메일의 "제보 위치"에 쓸 문구. 비어있으면 [title]을 사용한다.
  final String? pageContext;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BreadcrumbBar(items: breadcrumb),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [_TypeBadge(label: typeBadge), StatusChip(status: status)],
          ),
          const SizedBox(height: 12),
          AppHeader(
            title: title,
            description: summary,
            verifiedAt: verifiedAt,
            actions: [
              FavoriteButton(category: favoriteCategory, id: favoriteId),
              ShareButton(
                title: title,
                url: shareUrl,
                text: shareText ?? summary ?? title,
              ),
            ],
          ),
          if (infoChips.isNotEmpty) ...[
            Wrap(spacing: 8, runSpacing: 8, children: infoChips),
            const SizedBox(height: 20),
          ],
          body,
          if (related != null) ...[const SizedBox(height: 4), related!],
          const SizedBox(height: 8),
          SourceList(
            sourceIds: sourceIds,
            resolve: resolveSource,
            label: '출처 (${sourceIds.toSet().length}건 연결)',
          ),
          const SizedBox(height: 24),
          _ErrorReportButton(pageContext: pageContext ?? title),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _BreadcrumbBar extends StatelessWidget {
  const _BreadcrumbBar({required this.items});

  final List<DetailBreadcrumbItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final isLast = i == items.length - 1;
      if (item.route != null && !isLast) {
        children.add(
          InkWell(
            onTap: () => context.push(item.route!),
            child: Text(
              item.label,
              style: AppTextStyles.small.copyWith(
                color: AppColors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      } else {
        children.add(
          Text(
            item.label,
            style: AppTextStyles.small.copyWith(
              color: isLast ? AppColors.text : AppColors.muted,
              fontWeight: isLast ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        );
      }
      if (!isLast) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(
              Icons.chevron_right_rounded,
              size: 14,
              color: AppColors.muted,
            ),
          ),
        );
      }
    }
    return Semantics(
      container: true,
      label: '현재 위치: ${items.map((e) => e.label).join(' > ')}',
      child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: children),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.purple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.small.copyWith(
          color: AppColors.purple,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ErrorReportButton extends StatelessWidget {
  const _ErrorReportButton({required this.pageContext});

  final String pageContext;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => LinkService.openErrorReportEmail(
        context,
        pageContext: pageContext,
      ),
      icon: const Icon(Icons.flag_outlined, size: 18),
      label: const Text('이 페이지 오류 제보하기'),
    );
  }
}
