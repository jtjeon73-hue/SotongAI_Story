import 'package:flutter/material.dart';

import '../../core/utils/date_format_utils.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// 콘텐츠의 마지막 검증일을 표시하는 작은 배지.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, required this.verifiedAt});

  final String verifiedAt;

  @override
  Widget build(BuildContext context) {
    final label = DateFormatUtils.verifiedLabel(verifiedAt);
    return Tooltip(
      message: '이 콘텐츠가 마지막으로 검증된 날짜입니다.',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_rounded, size: 14, color: AppColors.teal),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.small),
        ],
      ),
    );
  }
}
