import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/menu_items.dart';
import '../../core/constants/route_paths.dart';
import '../../core/services/link_service.dart';
import '../../core/utils/date_format_utils.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// 데스크톱 사이드바(및 모바일 드로어)에서 공통으로 사용하는 내비게이션 목록.
///
/// [isDrawer]가 true면 항상 펼쳐진 상태로 표시하며 접기 버튼을 숨긴다.
/// 데스크톱 모드에서는 내부적으로 접힘 상태를 기억해, 탐색 시에도 유지한다.
/// 메뉴는 [MenuItems.groups]에 정의된 4개 그룹으로 나뉘어 표시되며, 펼침
/// 상태에서는 그룹 제목이 노출되고 접힘 상태(76px)에서는 숨겨진다.
class AppSidebar extends StatefulWidget {
  const AppSidebar({
    super.key,
    required this.currentPath,
    this.isDrawer = false,
    this.onNavigate,
  });

  final String currentPath;
  final bool isDrawer;
  final VoidCallback? onNavigate;

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  bool _collapsed = false;

  bool _isSelected(String route) {
    if (route == RoutePaths.home) return widget.currentPath == RoutePaths.home;
    return widget.currentPath == route ||
        widget.currentPath.startsWith('$route/');
  }

  @override
  Widget build(BuildContext context) {
    final collapsed = !widget.isDrawer && _collapsed;
    final width = widget.isDrawer
        ? AppConstants.sidebarExpandedWidth
        : (collapsed
              ? AppConstants.sidebarCollapsedWidth
              : AppConstants.sidebarExpandedWidth);

    return AnimatedContainer(
      duration: AppConstants.mediumAnimation,
      width: width,
      color: AppColors.navy,
      child: Column(
        children: [
          _buildBrandHeader(collapsed),
          const Divider(color: Colors.white24, height: 1),
          Expanded(
            // 메뉴 영역은 사이드바 안에서 독립적으로 스크롤된다.
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                for (final group in MenuItems.groups)
                  _MenuGroupSection(
                    group: group,
                    collapsed: collapsed,
                    isSelected: _isSelected,
                    onNavigate: widget.onNavigate,
                  ),
              ],
            ),
          ),
          if (!collapsed) _SidebarFooter(),
          if (!widget.isDrawer) _buildCollapseToggle(collapsed),
        ],
      ),
    );
  }

  Widget _buildBrandHeader(bool collapsed) {
    return SizedBox(
      height: AppConstants.headerHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: SvgPicture.asset(AppConstants.brandingIconSvg),
            ),
            if (!collapsed) ...[
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.appName,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${AppConstants.appNameEn} · by SotongWare',
                      style: AppTextStyles.small.copyWith(
                        color: Colors.white54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCollapseToggle(bool collapsed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Tooltip(
        message: collapsed ? '사이드바 펼치기' : '사이드바 접기',
        child: SizedBox(
          width: 44,
          height: 44,
          child: IconButton(
            onPressed: () => setState(() => _collapsed = !_collapsed),
            icon: Icon(
              collapsed
                  ? Icons.chevron_right_rounded
                  : Icons.chevron_left_rounded,
              color: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuGroupSection extends StatelessWidget {
  const _MenuGroupSection({
    required this.group,
    required this.collapsed,
    required this.isSelected,
    required this.onNavigate,
  });

  final MenuGroup group;
  final bool collapsed;
  final bool Function(String route) isSelected;
  final VoidCallback? onNavigate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!collapsed)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 12, 6),
            child: Text(
              group.title,
              style: AppTextStyles.small.copyWith(
                color: Colors.white38,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          )
        else
          const SizedBox(height: 12),
        for (final item in group.items)
          _MenuTile(
            item: item,
            collapsed: collapsed,
            selected: isSelected(item.route),
            onTap: () {
              context.go(item.route);
              onNavigate?.call();
            },
          ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.item,
    required this.collapsed,
    required this.selected,
    required this.onTap,
  });

  final MenuItem item;
  final bool collapsed;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: selected ? Colors.white.withValues(alpha: 0.08) : null,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(
            color: selected ? AppColors.gold : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: collapsed ? 10 : 12,
              vertical: 12,
            ),
            child: Row(
              mainAxisAlignment: collapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  item.icon,
                  size: 20,
                  color: selected ? Colors.white : Colors.white70,
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.title,
                      style: AppTextStyles.body.copyWith(
                        color: selected ? Colors.white : Colors.white70,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      selected: selected,
      label: item.title,
      hint: item.description,
      child: collapsed ? Tooltip(message: item.title, child: content) : content,
    );
  }
}

/// 사이드바 펼침 상태에서만 노출되는 하단 정보 영역.
///
/// 운영사, 콘텐츠 검증일, 오류 제보, 소개 페이지 링크를 간결하게 안내한다.
/// 접힘 상태(76px)에서는 공간이 부족해 숨긴다.
class _SidebarFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final repository = AppScope.of(context).repository;
    final verifiedDate = DateFormatUtils.formatKoreanDate(
      repository.siteUpdates.contentLastVerified,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '운영: ${AppConstants.operatorName}',
            style: AppTextStyles.small.copyWith(color: Colors.white70),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            '콘텐츠 검증일: $verifiedDate',
            style: AppTextStyles.small.copyWith(color: Colors.white54),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _FooterLink(
                  icon: Icons.mail_outline_rounded,
                  label: '오류 제보',
                  onTap: () => LinkService.openErrorReportEmail(
                    context,
                    pageContext: '사이드바',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FooterLink(
                  icon: Icons.info_outline_rounded,
                  label: '소개',
                  onTap: () => context.push(RoutePaths.about),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: Colors.white70),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: AppTextStyles.small.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
