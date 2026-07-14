import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_paths.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';

/// 서비스 운영사 소통웨어를 소개하는 하단 배너.
class SotongwareBanner extends StatelessWidget {
  const SotongwareBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.purple.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.purple.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.hub_rounded, color: AppColors.purple, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppConstants.operatorName}가 만들었습니다',
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: 4),
                Text(
                  '소통AI스토리는 소통웨어의 자동화·콘텐츠 제작 역량을 바탕으로 만들어진 서비스입니다. '
                  '소통웨어의 다른 사업 영역도 함께 살펴보세요.',
                  style: AppTextStyles.body.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.push(RoutePaths.about),
                  child: const Text('소통웨어 소개 보기'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
