import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_paths.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';

/// 존재하지 않는 경로에 접속했을 때 보여주는 친절한 404 페이지.
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.explore_off_rounded,
              size: 64,
              color: AppColors.muted,
            ),
            const SizedBox(height: 20),
            Text(
              '페이지를 찾을 수 없습니다',
              style: AppTextStyles.h1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              '요청하신 페이지가 삭제되었거나 주소가 변경되었을 수 있습니다.',
              style: AppTextStyles.body.copyWith(color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go(RoutePaths.home),
              icon: const Icon(Icons.home_rounded),
              label: const Text('홈으로 돌아가기'),
            ),
          ],
        ),
      ),
    );
  }
}
