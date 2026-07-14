import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// 데이터 로딩 중 표시하는 공용 위젯.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message = '콘텐츠를 불러오는 중입니다...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.blue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.body.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
