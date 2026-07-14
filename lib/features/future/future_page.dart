import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../core/models/future_trend.dart';
import '../../core/models/source.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/filter_chips.dart';
import '../../shared/widgets/source_list.dart';
import '../../shared/widgets/status_chip.dart';

/// AI 미래 전망 페이지. 전망을 유형별로 필터링해 카드로 보여준다.
class FuturePage extends StatefulWidget {
  const FuturePage({super.key});

  @override
  State<FuturePage> createState() => _FuturePageState();
}

class _FuturePageState extends State<FuturePage> {
  String? _type;

  @override
  Widget build(BuildContext context) {
    final repository = AppScope.of(context).repository;
    final trends = repository.futureTrends;
    final types = trends.map((t) => t.type).toSet().toList();

    final filtered = _type == null
        ? trends
        : trends.where((t) => t.type == _type).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppHeader(
            title: 'AI 미래 전망',
            description:
                '확인된 흐름부터 불확실한 시나리오까지, 근거 수준을 구분해 AI의 미래를 전망합니다. '
                '전망은 확정된 사실이 아니므로 유형 배지를 참고해 판단해주세요.',
          ),
          FilterChipsBar<String>(
            options: types
                .map(
                  (t) => FilterChipOption(
                    value: t,
                    label: futureTrendTypeLabel(t),
                  ),
                )
                .toList(),
            selected: _type,
            onSelected: (value) => setState(() => _type = value),
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            const EmptyStateView(title: '조건에 맞는 전망이 없습니다')
          else
            for (final trend in filtered)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _TrendCard(
                  trend: trend,
                  resolveSource: repository.sourceById,
                ),
              ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.trend, required this.resolveSource});

  final FutureTrend trend;
  final Source? Function(String id) resolveSource;

  Color get _typeColor {
    switch (trend.type) {
      case 'confirmed_trend':
        return AppColors.success;
      case 'official_forecast':
        return AppColors.blue;
      case 'analysis':
        return AppColors.purple;
      case 'uncertain_scenario':
        return AppColors.gold;
      default:
        return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  futureTrendTypeLabel(trend.type),
                  style: AppTextStyles.small.copyWith(color: _typeColor),
                ),
              ),
              StatusChip(status: trend.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(trend.title, style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text(trend.currentEvidence, style: AppTextStyles.body),
          const SizedBox(height: 10),
          Text(
            '가능성: ${trend.possibility}',
            style: AppTextStyles.small.copyWith(color: AppColors.muted),
          ),
          if (trend.expectedEffects.isNotEmpty) ...[
            const SizedBox(height: 10),
            _bullets(
              '예상 효과',
              trend.expectedEffects,
              Icons.trending_up_rounded,
              AppColors.success,
            ),
          ],
          if (trend.risks.isNotEmpty) ...[
            const SizedBox(height: 10),
            _bullets(
              '위험 요인',
              trend.risks,
              Icons.warning_amber_rounded,
              AppColors.error,
            ),
          ],
          if (trend.individualPrep.isNotEmpty) ...[
            const SizedBox(height: 10),
            _bullets(
              '개인 대비',
              trend.individualPrep,
              Icons.person_outline_rounded,
              AppColors.blue,
            ),
          ],
          if (trend.businessPrep.isNotEmpty) ...[
            const SizedBox(height: 10),
            _bullets(
              '기업 대비',
              trend.businessPrep,
              Icons.apartment_rounded,
              AppColors.teal,
            ),
          ],
          if (trend.publicPrep.isNotEmpty) ...[
            const SizedBox(height: 10),
            _bullets(
              '공공 대비',
              trend.publicPrep,
              Icons.public_rounded,
              AppColors.purple,
            ),
          ],
          const SizedBox(height: 12),
          SourceList(sourceIds: trend.sourceIds, resolve: resolveSource),
        ],
      ),
    );
  }

  Widget _bullets(
    String title,
    List<String> items,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.small.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: 4),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 15, color: color),
                const SizedBox(width: 6),
                Expanded(child: Text(item, style: AppTextStyles.body)),
              ],
            ),
          ),
      ],
    );
  }
}
