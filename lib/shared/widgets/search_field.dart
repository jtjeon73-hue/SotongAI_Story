import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 검색어 입력용 공용 텍스트 필드.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    this.hintText = '검색어를 입력하세요',
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: hintText,
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.muted),
          suffixIcon: ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                tooltip: '지우기',
                icon: const Icon(Icons.clear_rounded, size: 18),
                onPressed: () {
                  controller.clear();
                  onChanged?.call('');
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
