import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/services/pwa_update_service.dart';
import '../shared/theme/app_colors.dart';
import '../shared/theme/app_theme.dart';
import 'app_router.dart';

/// 앱 루트 위젯. go_router 기반 [MaterialApp.router]를 구성한다.
///
/// 웹에서는 새 버전이 배포되어 서비스 워커가 교체되면([PwaUpdateService])
/// 화면 최상단에 새로고침을 안내하는 [MaterialBanner]를 띄운다.
class SotongAiStoryApp extends StatefulWidget {
  const SotongAiStoryApp({super.key});

  @override
  State<SotongAiStoryApp> createState() => _SotongAiStoryAppState();
}

class _SotongAiStoryAppState extends State<SotongAiStoryApp> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  bool _bannerShown = false;

  @override
  void initState() {
    super.initState();
    PwaUpdateService.listenForUpdate(_showUpdateBanner);
  }

  void _showUpdateBanner() {
    if (_bannerShown) return;
    _bannerShown = true;
    _scaffoldMessengerKey.currentState?.showMaterialBanner(
      MaterialBanner(
        backgroundColor: AppColors.navy,
        content: const Text(
          '새 버전이 있습니다. 새로고침하면 최신 콘텐츠를 볼 수 있어요.',
          style: TextStyle(color: Colors.white),
        ),
        leading: const Icon(Icons.system_update_rounded, color: Colors.white),
        actions: [
          TextButton(
            onPressed: () {
              _scaffoldMessengerKey.currentState?.hideCurrentMaterialBanner();
              _bannerShown = false;
            },
            child: const Text('나중에', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: PwaUpdateService.reload,
            child: const Text('새로고침', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      scaffoldMessengerKey: _scaffoldMessengerKey,
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
      locale: const Locale('ko', 'KR'),
    );
  }
}
