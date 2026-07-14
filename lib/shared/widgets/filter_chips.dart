import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// 필터용 선택 옵션 하나.
class FilterChipOption<T> {
  const FilterChipOption({required this.value, required this.label});

  final T value;
  final String label;
}

/// 단일 선택 필터 칩 그룹.
///
/// [selected]가 null이면 '전체'에 해당하는 상태로 간주한다.
class FilterChipsBar<T> extends StatelessWidget {
  const FilterChipsBar({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.allLabel = '전체',
  });

  final List<FilterChipOption<T>> options;
  final T? selected;
  final ValueChanged<T?> onSelected;
  final String allLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _chip(
            context,
            label: allLabel,
            isSelected: selected == null,
            onTap: () => onSelected(null),
          ),
          const SizedBox(width: 8),
          for (final option in options) ...[
            _chip(
              context,
              label: option.label,
              isSelected: selected == option.value,
              onTap: () => onSelected(option.value),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      selected: isSelected,
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.blue.withValues(alpha: 0.12),
        labelStyle: AppTextStyles.small.copyWith(
          color: isSelected ? AppColors.blue : AppColors.text,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
        side: BorderSide(color: isSelected ? AppColors.blue : AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
