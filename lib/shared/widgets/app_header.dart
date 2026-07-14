import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'verified_badge.dart';

/// 각 기능 페이지 상단에서 공통으로 사용하는 헤더.
///
/// 제목, 설명, (선택) 검증일 배지, (선택) 검색 필드, (선택) 우측 액션 버튼들
/// (즐겨찾기·공유 등)을 조합한다.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.description,
    this.verifiedAt,
    this.searchField,
    this.actions = const [],
  });

  final String title;
  final String? description;
  final String? verifiedAt;
  final Widget? searchField;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(title, style: AppTextStyles.h1),
                ),
              ),
              if (actions.isNotEmpty) Wrap(spacing: 4, children: actions),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(
              description!,
              style: AppTextStyles.body.copyWith(color: AppColors.muted),
            ),
          ],
          if (verifiedAt != null) ...[
            const SizedBox(height: 10),
            VerifiedBadge(verifiedAt: verifiedAt!),
          ],
          if (searchField != null) ...[
            const SizedBox(height: 16),
            searchField!,
          ],
        ],
      ),
    );
  }
}
