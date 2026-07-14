import 'package:flutter/material.dart';

import '../layout/responsive_layout.dart';

/// 화면 폭에 따라 열 수가 달라지는 반응형 그리드.
///
/// 데스크톱 3열, 태블릿 2열, 모바일 1열을 기본값으로 사용한다.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.desktopColumns = 3,
    this.tabletColumns = 2,
    this.mobileColumns = 1,
    this.spacing = 16,
    this.childAspectRatio,
  });

  final List<Widget> children;
  final int desktopColumns;
  final int tabletColumns;
  final int mobileColumns;
  final double spacing;
  final double? childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = ResponsiveLayout.isDesktop(width)
            ? desktopColumns
            : ResponsiveLayout.isTablet(width)
            ? tabletColumns
            : mobileColumns;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: children.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: childAspectRatio ?? 1.15,
          ),
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}
