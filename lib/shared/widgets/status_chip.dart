import 'package:flutter/material.dart';

import '../../core/models/content_status.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// [ContentStatus]를 색상이 있는 작은 배지로 표시하는 위젯.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final ContentStatus status;

  Color get _color {
    switch (status) {
      case ContentStatus.verified:
        return AppColors.success;
      case ContentStatus.partiallyVerified:
        return AppColors.gold;
      case ContentStatus.forecast:
        return AppColors.purple;
      case ContentStatus.active:
        return AppColors.blue;
      case ContentStatus.inactive:
        return AppColors.muted;
      case ContentStatus.verificationRequired:
        return AppColors.gold;
      case ContentStatus.expired:
        return AppColors.error;
      case ContentStatus.unknown:
        return AppColors.muted;
    }
  }

  IconData get _icon {
    switch (status) {
      case ContentStatus.verified:
        return Icons.check_circle_rounded;
      case ContentStatus.partiallyVerified:
        return Icons.info_rounded;
      case ContentStatus.forecast:
        return Icons.auto_graph_rounded;
      case ContentStatus.active:
        return Icons.bolt_rounded;
      case ContentStatus.inactive:
        return Icons.pause_circle_rounded;
      case ContentStatus.verificationRequired:
        return Icons.error_outline_rounded;
      case ContentStatus.expired:
        return Icons.event_busy_rounded;
      case ContentStatus.unknown:
        return Icons.help_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Semantics(
      label: status.label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              status.label,
              style: AppTextStyles.small.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
