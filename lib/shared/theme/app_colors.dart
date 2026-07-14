import 'package:flutter/material.dart';

/// 앱 전역 색상 시스템.
///
/// 요구사항에 명시된 고정 팔레트를 그대로 상수로 노출한다.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFFF4F7FB);
  static const Color card = Color(0xFFFFFFFF);
  static const Color navy = Color(0xFF13243A);
  static const Color blue = Color(0xFF2764D8);
  static const Color teal = Color(0xFF14A8A0);
  static const Color purple = Color(0xFF7357D9);
  static const Color gold = Color(0xFFE8AA32);
  static const Color text = Color(0xFF182437);
  static const Color muted = Color(0xFF607086);
  static const Color border = Color(0xFFDCE4EE);
  static const Color error = Color(0xFFC63E47);
  static const Color success = Color(0xFF198754);

  /// 카테고리별 강조색으로 사용할 팔레트. 태그·배지·차트 등에서 순환 사용.
  static const List<Color> accentCycle = [blue, teal, purple, gold];
}
