import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/external_links.dart';
import '../../core/services/link_service.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/responsive_grid.dart';

/// 소통웨어 소개 페이지.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppHeader(
            title: '소통웨어 소개',
            description:
                '${AppConstants.appName}는 ${AppConstants.operatorName}이 만들고 운영하는 서비스입니다.',
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: SvgPicture.asset(AppConstants.brandingIconSvg),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.appName,
                        style: AppTextStyles.h1.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppConstants.appSlogan,
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text('소통웨어는 이런 일을 합니다', style: AppTextStyles.h2),
          const SizedBox(height: 6),
          Text(
            'AI와 자동화 기술을 활용해 실생활과 업무에 실질적인 도움이 되는 제품과 콘텐츠를 만듭니다.',
            style: AppTextStyles.body.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          ResponsiveGrid(
            children: ExternalLinks.businessAreas
                .map((item) => _BusinessAreaCard(item: item))
                .toList(),
          ),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('문의 및 오류 제보', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                Text(
                  '${AppConstants.appName} 콘텐츠에 대한 문의나 오류 제보는 아래 이메일로 보내주세요.',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => LinkService.openErrorReportEmail(
                    context,
                    pageContext: '소통웨어 소개',
                  ),
                  icon: const Icon(Icons.mail_outline_rounded),
                  label: Text(AppConstants.contactEmail),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BusinessAreaCard extends StatelessWidget {
  const _BusinessAreaCard({required this.item});

  final ExternalLinkItem item;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: item.title,
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => LinkService.openUrl(context, item.url),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: AppTextStyles.h3),
                const SizedBox(height: 8),
                Text(
                  item.description,
                  style: AppTextStyles.body.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Text(
                      '자세히 보기',
                      style: TextStyle(
                        color: AppColors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: AppColors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
