import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../shared/theme/app_theme.dart';
import 'app_router.dart';

/// 앱 루트 위젯. go_router 기반 [MaterialApp.router]를 구성한다.
class SotongAiStoryApp extends StatelessWidget {
  const SotongAiStoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
      locale: const Locale('ko', 'KR'),
    );
  }
}
