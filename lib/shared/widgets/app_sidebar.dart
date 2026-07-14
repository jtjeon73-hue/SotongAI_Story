import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/menu_items.dart';
import '../../core/constants/route_paths.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// 데스크톱 사이드바(및 모바일 드로어)에서 공통으로 사용하는 내비게이션 목록.
///
/// [isDrawer]가 true면 항상 펼쳐진 상태로 표시하며 접기 버튼을 숨긴다.
/// 데스크톱 모드에서는 내부적으로 접힘 상태를 기억해, 탐색 시에도 유지한다.
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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: MenuItems.all.length,
              itemBuilder: (context, index) {
                final item = MenuItems.all[index];
                return _MenuTile(
                  item: item,
                  collapsed: collapsed,
                  selected: _isSelected(item.route),
                  onTap: () {
                    context.go(item.route);
                    widget.onNavigate?.call();
                  },
                );
              },
            ),
          ),
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
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.hub_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            if (!collapsed) ...[
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppConstants.appName,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
