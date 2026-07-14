import 'package:flutter_test/flutter_test.dart';
import 'package:sotong_ai_story/shared/layout/responsive_layout.dart';

void main() {
  group('ResponsiveLayout', () {
    test('1100 이상은 데스크톱으로 판별한다', () {
      expect(ResponsiveLayout.isDesktop(1100), isTrue);
      expect(ResponsiveLayout.isDesktop(1440), isTrue);
      expect(ResponsiveLayout.isDesktop(1099.9), isFalse);
    });

    test('720 이상 1100 미만은 태블릿으로 판별한다', () {
      expect(ResponsiveLayout.isTablet(720), isTrue);
      expect(ResponsiveLayout.isTablet(900), isTrue);
      expect(ResponsiveLayout.isTablet(1099.9), isTrue);
      expect(ResponsiveLayout.isTablet(1100), isFalse);
      expect(ResponsiveLayout.isTablet(500), isFalse);
    });

    test('720 미만은 모바일로 판별한다', () {
      expect(ResponsiveLayout.isMobile(719.9), isTrue);
      expect(ResponsiveLayout.isMobile(360), isTrue);
      expect(ResponsiveLayout.isMobile(720), isFalse);
    });
  });
}
