import 'package:flutter/material.dart';

import '../layout/responsive_layout.dart';

/// 화면 폭에 따라 열 수가 달라지는 반응형 그리드.
///
/// 데스크톱 3열, 태블릿 2열, 모바일 1열을 기본값으로 사용한다.
///
/// 기본 모드는 [childAspectRatio]로 카드 높이를 고정하는 [GridView]를
/// 사용하지만, 카드 내용 길이가 서로 달라 잘림이 발생할 수 있는 화면(AI 툴
/// 탐색 등)에서는 [useAutoHeight]를 true로 설정하면 [Wrap] 기반으로 각 카드가
/// 스스로 필요한 높이만큼 늘어나는 레이아웃을 사용한다.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.desktopColumns = 3,
    this.tabletColumns = 2,
    this.mobileColumns = 1,
    this.spacing = 16,
    this.childAspectRatio,
    this.useAutoHeight = false,
  });

  final List<Widget> children;
  final int desktopColumns;
  final int tabletColumns;
  final int mobileColumns;
  final double spacing;
  final double? childAspectRatio;

  /// true면 카드 높이를 고정하지 않고 내용에 맞춰 자동으로 늘어나게 한다.
  final bool useAutoHeight;

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

        if (useAutoHeight) {
          final totalGap = spacing * (columns - 1);
          final itemWidth = columns > 1
              ? (width - totalGap) / columns
              : width;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: children
                .map((child) => SizedBox(width: itemWidth, child: child))
                .toList(),
          );
        }

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
