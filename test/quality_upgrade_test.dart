import 'package:flutter_test/flutter_test.dart';
import 'package:sotong_ai_story/core/constants/app_constants.dart';
import 'package:sotong_ai_story/core/constants/external_links.dart';
import 'package:sotong_ai_story/core/constants/menu_items.dart';
import 'package:sotong_ai_story/core/models/ai_tool.dart';
import 'package:sotong_ai_story/core/models/api_availability.dart';
import 'package:sotong_ai_story/core/models/content_status.dart';
import 'package:sotong_ai_story/core/models/field_evidence.dart';
import 'package:sotong_ai_story/core/models/korean_support_level.dart';
import 'package:sotong_ai_story/core/models/local_execution_level.dart';
import 'package:sotong_ai_story/core/models/pricing_kind.dart';
import 'package:sotong_ai_story/core/models/verification_stats.dart';
import 'package:sotong_ai_story/core/services/seo_meta_service.dart';
import 'package:sotong_ai_story/features/tools/tools_filter_state.dart';

void main() {
  group('ContentStatus', () {
    test('verificationRequired를 unknown으로 매핑하지 않는다', () {
      expect(
        ContentStatus.fromJson('verificationRequired'),
        ContentStatus.verificationRequired,
      );
      expect(ContentStatus.verificationRequired.label, '검증 필요');
    });
  });

  group('AiTool enums & fieldEvidence', () {
    test('새 레벨 필드를 파싱한다', () {
      final tool = AiTool.fromJson(const {
        'id': 't1',
        'name': 'Tool',
        'pricingKind': 'freemium',
        'koreanSupportLevel': 'partial',
        'apiAvailability': 'official',
        'localExecutionLevel': 'notSupported',
        'fieldEvidence': [
          {
            'field': 'pricing',
            'status': 'partiallyVerified',
            'sourceIds': ['src-1'],
            'checkedAt': '2026-07-01',
            'expiresAt': '2026-08-01',
            'note': '가격 페이지 확인',
          },
        ],
        'freeTierAvailable': true,
        'freeTrialAvailable': null,
      });

      expect(tool.pricingKind, PricingKind.freemium);
      expect(tool.koreanSupportLevel, KoreanSupportLevel.partial);
      expect(tool.apiAvailability, ApiAvailability.official);
      expect(tool.localExecutionLevel, LocalExecutionLevel.notSupported);
      expect(tool.fieldEvidence, hasLength(1));
      expect(tool.freeTierAvailable, isTrue);
      expect(tool.freeTrialAvailable, isNull);
    });

    test('레거시 bool만 있어도 unknown과 false를 혼동하지 않는다', () {
      final unknownKorean = AiTool.fromJson(const {
        'id': 't2',
        'name': 'U',
        'koreanSupportNote': '공식 사이트 확인 필요',
      });
      expect(unknownKorean.koreanSupportLevel, KoreanSupportLevel.unknown);

      final noApi = AiTool.fromJson(const {
        'id': 't3',
        'name': 'N',
        'apiAvailable': false,
      });
      expect(noApi.apiAvailability, ApiAvailability.none);
    });

    test('만료된 fieldEvidence는 재검증 필요로 본다', () {
      final evidence = FieldEvidence.fromJson(const {
        'field': 'api',
        'status': 'verified',
        'checkedAt': '2024-01-01',
        'expiresAt': '2024-03-01',
      });
      expect(evidence.isExpired, isTrue);
      expect(evidence.effectiveStatus, EvidenceStatus.verificationRequired);
    });
  });

  group('ToolsFilterState', () {
    test('URL query와 왕복한다', () {
      const state = ToolsFilterState(
        query: 'gpt',
        category: 'conversation',
        pricingKind: PricingKind.freemium,
        koreanLevel: KoreanSupportLevel.full,
      );
      final params = state.toQueryParameters();
      final restored = ToolsFilterState.fromQueryParameters(params);
      expect(restored.query, 'gpt');
      expect(restored.category, 'conversation');
      expect(restored.pricingKind, PricingKind.freemium);
      expect(restored.koreanLevel, KoreanSupportLevel.full);
    });

    test('초기화하면 검색어와 필터가 비워진다', () {
      final cleared = const ToolsFilterState(
        query: 'x',
        category: 'coding',
      ).copyWith(query: '', category: null);
      expect(cleared.query, isEmpty);
      expect(cleared.category, isNull);
      expect(cleared.hasActiveFilters, isFalse);
    });
  });

  group('VerificationStats', () {
    test('통계 객체를 구성할 수 있다', () {
      const stats = VerificationStats(
        total: 6,
        verified: 2,
        partiallyVerified: 1,
        verificationRequired: 1,
        expired: 0,
        forecast: 1,
        active: 1,
        discontinued: 0,
        unknown: 0,
        missingSources: 0,
      );
      expect(stats.total, 6);
      expect(stats.needsAttention, 1);
      expect(stats.verifiedRatio, closeTo(0.5, 0.01));
    });
  });

  group('Menu groups & branding', () {
    test('사이드바 메뉴가 4개 그룹으로 구성된다', () {
      expect(MenuItems.groups, hasLength(4));
      final titles = MenuItems.groups.map((g) => g.title).toList();
      expect(titles, contains('AI 이해하기'));
      expect(titles, contains('AI 도구와 활용'));
      expect(titles, contains('산업과 사회'));
      expect(titles, contains('신뢰와 운영'));
      final routes = MenuItems.groups.expand((g) => g.items).map((m) => m.route);
      expect(routes, contains('/'));
      expect(routes, contains('/about'));
    });

    test('브랜드 SVG 경로가 설정되어 있다', () {
      expect(AppConstants.brandingIconSvg, contains('sotong_ai_story_icon.svg'));
    });

    test('외부 링크에 관제/control URL이 없다', () {
      for (final item in ExternalLinks.businessAreas) {
        expect(item.url.contains('control'), isFalse);
        expect(item.url.contains('sotongware.com'), isFalse);
      }
    });
  });

  group('SEO meta', () {
    test('경로별 title과 canonical을 생성한다', () {
      final home = SeoMetaService.resolve('/');
      expect(home.title, contains('소통AI스토리'));
      expect(home.canonicalUrl, contains('sotongware-ai-story.web.app'));

      final tools = SeoMetaService.resolve('/tools');
      expect(tools.title.toLowerCase(), contains('툴'));
      expect(tools.canonicalUrl.endsWith('/tools'), isTrue);
      expect(tools.title.isNotEmpty, isTrue);
    });
  });
}
