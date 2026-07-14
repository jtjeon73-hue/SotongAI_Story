import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_paths.dart';
import '../../../shared/layout/responsive_layout.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';

/// 홈 화면 최상단 히어로 섹션. 서비스 소개와 4개의 CTA 버튼을 표시한다.
class HomeHero extends StatelessWidget {
  const HomeHero({super.key});

  static const _ctas = [
    _HeroCta(
      label: 'AI 역사 연대표 보기',
      icon: Icons.timeline_rounded,
      route: RoutePaths.timeline,
    ),
    _HeroCta(
      label: 'AI 툴 탐색하기',
      icon: Icons.explore_rounded,
      route: RoutePaths.tools,
    ),
    _HeroCta(
      label: '실전 워크플로 보기',
      icon: Icons.account_tree_rounded,
      route: RoutePaths.workflows,
    ),
    _HeroCta(
      label: 'AI 용어사전',
      icon: Icons.menu_book_rounded,
      route: RoutePaths.glossary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktopOf(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 20,
        vertical: isDesktop ? 48 : 32,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.navy, Color(0xFF1B3A5C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              AppConstants.appName,
              style: AppTextStyles.display.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Text(
              '1950년부터 오늘날의 생성형 AI까지, 출처가 명확한 정보로 AI의 역사와 현재를 안내합니다. '
              'AI 개념, 도구, 활용사례를 한 곳에서 검증된 콘텐츠로 만나보세요.',
              style: AppTextStyles.body.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _ctas
                .map((cta) => _buildCtaButton(context, cta))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCtaButton(BuildContext context, _HeroCta cta) {
    return Semantics(
      button: true,
      label: cta.label,
      child: OutlinedButton.icon(
        onPressed: () => context.push(cta.route),
        icon: Icon(cta.icon, size: 18, color: Colors.white),
        label: Text(
          cta.label,
          style: AppTextStyles.button.copyWith(color: Colors.white),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
          backgroundColor: Colors.white.withValues(alpha: 0.06),
        ),
      ),
    );
  }
}

class _HeroCta {
  const _HeroCta({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}
