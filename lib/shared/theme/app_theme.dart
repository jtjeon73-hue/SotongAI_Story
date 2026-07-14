import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// 앱 전역 [ThemeData] 빌더.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      brightness: Brightness.light,
      primary: AppColors.blue,
      secondary: AppColors.teal,
      tertiary: AppColors.purple,
      error: AppColors.error,
      surface: AppColors.card,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppTextStyles.body.fontFamily,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.display,
        headlineLarge: AppTextStyles.h1,
        headlineMedium: AppTextStyles.h2,
        headlineSmall: AppTextStyles.h3,
        titleMedium: AppTextStyles.titleMedium,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.body,
        labelLarge: AppTextStyles.button,
        bodySmall: AppTextStyles.caption,
        labelSmall: AppTextStyles.small,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.text,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0.5,
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.background,
        selectedColor: AppColors.blue.withValues(alpha: 0.12),
        labelStyle: AppTextStyles.small.copyWith(color: AppColors.text),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          minimumSize: const Size(44, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          side: const BorderSide(color: AppColors.border),
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          minimumSize: const Size(44, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.blue,
          textStyle: AppTextStyles.button,
          minimumSize: const Size(44, 44),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.navy),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTextStyles.small.copyWith(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
        ),
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.muted),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.navy,
        contentTextStyle: AppTextStyles.body.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      visualDensity: VisualDensity.standard,
    );
  }
}
