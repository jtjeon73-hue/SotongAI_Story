import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../widgets/app_sidebar.dart';

/// 데스크톱 레이아웃: 좌측 고정 사이드바 + 우측 독립 스크롤 콘텐츠 영역.
class DesktopShell extends StatelessWidget {
  const DesktopShell({
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
      body: Row(
        children: [
          AppSidebar(currentPath: currentPath),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppConstants.contentMaxWidth,
                ),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
