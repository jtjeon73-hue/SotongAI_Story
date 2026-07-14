import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// 검색·필터 결과가 없을 때 표시하는 공용 위젯.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    this.icon = Icons.inbox_rounded,
    this.title = '표시할 콘텐츠가 없습니다',
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.muted, size: 44),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.h3, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: AppTextStyles.body.copyWith(color: AppColors.muted),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}
