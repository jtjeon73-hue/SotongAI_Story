import 'package:flutter_test/flutter_test.dart';
import 'package:sotong_ai_story/core/models/ai_tool.dart';
import 'package:sotong_ai_story/core/models/content_status.dart';
import 'package:sotong_ai_story/core/models/source.dart';
import 'package:sotong_ai_story/core/models/timeline_entry.dart';

void main() {
  group('Source.fromJson', () {
    test('필드를 정확히 매핑한다', () {
      final source = Source.fromJson(const {
        'id': 'src-1',
        'title': '테스트 출처',
        'publisher': '테스트 발행처',
        'url': 'https://example.com',
        'publishedDate': '2024-01-01',
        'accessedDate': '2024-01-02',
        'sourceType': 'official',
        'language': 'ko',
        'note': '참고용',
      });

      expect(source.id, 'src-1');
      expect(source.title, '테스트 출처');
      expect(source.publisher, '테스트 발행처');
      expect(source.url, 'https://example.com');
      expect(source.sourceType, 'official');
    });

    test('필드가 없어도 예외 없이 기본값으로 채운다', () {
      final source = Source.fromJson(const {});
      expect(source.id, '');
      expect(source.title, '');
      expect(source.note, '');
    });
  });

  group('TimelineEntry.fromJson', () {
    test('필드를 정확히 매핑하고 상태를 파싱한다', () {
      final entry = TimelineEntry.fromJson(const {
        'id': 'tl-1',
        'title': '테스트 사건',
        'summary': '요약',
        'year': 2020,
        'month': 5,
        'dateText': '2020년 5월',
        'datePrecision': 'month',
        'era': 'modern',
        'category': 'research',
        'importance': 4,
        'details': '상세',
        'background': '배경',
        'whyItMatters': '중요성',
        'currentConnection': '현재 연결',
        'relatedPeople': ['홍길동'],
        'relatedOrganizations': ['테스트기관'],
        'tags': ['tag1'],
        'sourceIds': ['src-1'],
        'verifiedAt': '2024-01-01',
        'status': 'verified',
      });

      expect(entry.id, 'tl-1');
      expect(entry.year, 2020);
      expect(entry.month, 5);
      expect(entry.status, ContentStatus.verified);
      expect(entry.tags, ['tag1']);
    });

    test('month가 없으면 null을 유지한다', () {
      final entry = TimelineEntry.fromJson(const {'id': 'tl-2', 'year': 1956});
      expect(entry.month, isNull);
      expect(entry.year, 1956);
      expect(entry.status, ContentStatus.unknown);
    });
  });

  group('AiTool.fromJson', () {
    test('불리언·리스트 필드를 정확히 매핑한다', () {
      final tool = AiTool.fromJson(const {
        'id': 'tool-1',
        'name': '테스트 도구',
        'company': '테스트 회사',
        'category': 'conversation',
        'description': '설명',
        'officialUrl': 'https://example.com',
        'pricingType': 'freemium',
        'koreanSupport': true,
        'apiAvailable': false,
        'keyFeatures': ['기능1', '기능2'],
        'isPopular': true,
        'isHiddenGem': false,
      });

      expect(tool.name, '테스트 도구');
      expect(tool.koreanSupport, isTrue);
      expect(tool.apiAvailable, isFalse);
      expect(tool.isFree, isTrue);
      expect(tool.keyFeatures, ['기능1', '기능2']);
      expect(tool.isPopular, isTrue);
    });
  });
}
