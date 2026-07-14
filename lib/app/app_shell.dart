import 'package:flutter/material.dart';

import '../shared/layout/desktop_shell.dart';
import '../shared/layout/mobile_shell.dart';
import '../shared/layout/responsive_layout.dart';

/// go_router ShellRoute의 뼈대 위젯.
///
/// 화면 폭에 따라 [DesktopShell] 또는 [MobileShell]로 분기하며, 현재 페이지
/// 콘텐츠([child])와 현재 경로([currentPath])를 그대로 전달한다.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.currentPath, required this.child});

  final String currentPath;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (ResponsiveLayout.isDesktop(constraints.maxWidth)) {
          return DesktopShell(currentPath: currentPath, child: child);
        }
        return MobileShell(currentPath: currentPath, child: child);
      },
    );
  }
}
