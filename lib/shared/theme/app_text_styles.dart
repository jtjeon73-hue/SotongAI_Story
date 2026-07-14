import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Noto Sans KR 기반 텍스트 스타일 모음.
///
/// 위젯에서 `AppTextStyles.h1` 형태로 바로 참조할 수 있도록 static getter로 제공한다.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _base => GoogleFonts.notoSansKr(color: AppColors.text);

  static TextStyle get display => _base.copyWith(
    fontSize: 40,
    fontWeight: FontWeight.w800,
    height: 1.25,
    letterSpacing: -0.5,
  );

  static TextStyle get h1 => _base.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.3,
    letterSpacing: -0.3,
  );

  static TextStyle get h2 =>
      _base.copyWith(fontSize: 22, fontWeight: FontWeight.w700, height: 1.35);

  static TextStyle get h3 =>
      _base.copyWith(fontSize: 18, fontWeight: FontWeight.w700, height: 1.4);

  static TextStyle get titleMedium =>
      _base.copyWith(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4);

  static TextStyle get body =>
      _base.copyWith(fontSize: 15, fontWeight: FontWeight.w400, height: 1.6);

  static TextStyle get bodyStrong =>
      _base.copyWith(fontSize: 15, fontWeight: FontWeight.w600, height: 1.6);

  static TextStyle get caption => _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.muted,
  );

  static TextStyle get small => _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.muted,
  );

  static TextStyle get button =>
      _base.copyWith(fontSize: 15, fontWeight: FontWeight.w700, height: 1.2);
}
