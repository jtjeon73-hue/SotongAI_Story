import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/route_paths.dart';
import '../theme/app_colors.dart';
import '../widgets/app_sidebar.dart';

/// 모바일/태블릿 레이아웃: 상단 앱바 + 드로어 내비게이션.
class MobileShell extends StatelessWidget {
  const MobileShell({
    super.key,
    required this.currentPath,
    required this.child,
  });

  final String currentPath;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppConstants.appName),
        actions: [
          Tooltip(
            message: '즐겨찾기',
            child: IconButton(
              icon: const Icon(Icons.favorite_border_rounded),
              onPressed: () => context.push(RoutePaths.favorites),
            ),
          ),
          Tooltip(
            message: '검색',
            child: IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () => context.push(RoutePaths.search),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppColors.navy,
        child: SafeArea(
          child: AppSidebar(
            currentPath: currentPath,
            isDrawer: true,
            onNavigate: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: SafeArea(child: child),
    );
  }
}
