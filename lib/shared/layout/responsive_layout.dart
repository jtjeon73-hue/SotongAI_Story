import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

/// 화면 폭에 따른 반응형 브레이크포인트 판별 헬퍼.
class ResponsiveLayout {
  ResponsiveLayout._();

  /// 폭이 데스크톱 브레이크포인트(1100) 이상이면 true.
  static bool isDesktop(double width) =>
      width >= AppConstants.desktopBreakpoint;

  /// 폭이 태블릿 브레이크포인트(720) 이상, 데스크톱 미만이면 true.
  static bool isTablet(double width) =>
      width >= AppConstants.tabletBreakpoint &&
      width < AppConstants.desktopBreakpoint;

  /// 폭이 태블릿 브레이크포인트 미만이면 true.
  static bool isMobile(double width) => width < AppConstants.tabletBreakpoint;

  /// [BuildContext]의 현재 폭을 기준으로 데스크톱 여부를 반환한다.
  static bool isDesktopOf(BuildContext context) =>
      isDesktop(MediaQuery.sizeOf(context).width);
}
