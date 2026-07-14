import 'package:flutter/material.dart';

import '../../core/models/source.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_paths.dart';

/// 출처 하나를 나타내는 작은 클릭 가능한 배지.
///
/// 탭하면 출처·검증센터 페이지로 이동한다(전체 출처 목록에서 해당 항목을
/// 강조하는 것은 향후 개선 과제로 남기고, 현재는 센터 페이지로 이동한다).
class SourceBadge extends StatelessWidget {
  const SourceBadge({super.key, required this.source});

  final Source source;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: source.note.isEmpty ? source.publisher : source.note,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.push(RoutePaths.sources),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.description_outlined,
                size: 13,
                color: AppColors.muted,
              ),
              const SizedBox(width: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: Text(
                  source.title,
                  style: AppTextStyles.small,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
