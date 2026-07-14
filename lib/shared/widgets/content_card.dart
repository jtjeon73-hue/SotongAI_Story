import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// 목록/그리드에서 공통으로 사용하는 콘텐츠 카드.
///
/// 제목, 설명, 태그(칩) 목록, 하단 영역(상태 배지 등), 우측 상단 액션
/// (즐겨찾기 버튼 등)을 조합해 다양한 콘텐츠 종류에 재사용할 수 있다.
class ContentCard extends StatelessWidget {
  const ContentCard({
    super.key,
    required this.title,
    this.subtitle,
    this.description,
    this.tags = const [],
    this.accentColor = AppColors.blue,
    this.leadingIcon,
    this.trailing,
    this.footer,
    this.onTap,
    this.semanticLabel,
  });

  final String title;
  final String? subtitle;
  final String? description;
  final List<String> tags;
  final Color accentColor;
  final IconData? leadingIcon;
  final Widget? trailing;
  final Widget? footer;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: semanticLabel ?? title,
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (leadingIcon != null) ...[
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(leadingIcon, color: accentColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.h3,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              style: AppTextStyles.small.copyWith(
                                color: accentColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    ?trailing,
                  ],
                ),
                if (description != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    description!,
                    style: AppTextStyles.body.copyWith(color: AppColors.muted),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: tags
                        .take(4)
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(tag, style: AppTextStyles.small),
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (footer != null) ...[const SizedBox(height: 12), footer!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
