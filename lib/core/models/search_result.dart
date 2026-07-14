import 'package:flutter/material.dart';

import 'content_status.dart';

/// 검색 결과가 가리키는 콘텐츠 종류.
enum SearchResultType {
  timeline,
  era,
  concept,
  tool,
  useCase,
  workflow,
  glossary,
  futureTrend,
  source,
}

extension SearchResultTypeX on SearchResultType {
  String get label {
    switch (this) {
      case SearchResultType.timeline:
        return '연대표';
      case SearchResultType.era:
        return '시대';
      case SearchResultType.concept:
        return '핵심 개념';
      case SearchResultType.tool:
        return 'AI 툴';
      case SearchResultType.useCase:
        return '활용사례';
      case SearchResultType.workflow:
        return '워크플로';
      case SearchResultType.glossary:
        return '용어사전';
      case SearchResultType.futureTrend:
        return '미래 전망';
      case SearchResultType.source:
        return '출처';
    }
  }

  IconData get icon {
    switch (this) {
      case SearchResultType.timeline:
        return Icons.timeline_rounded;
      case SearchResultType.era:
        return Icons.history_edu_rounded;
      case SearchResultType.concept:
        return Icons.psychology_rounded;
      case SearchResultType.tool:
        return Icons.smart_toy_rounded;
      case SearchResultType.useCase:
        return Icons.business_center_rounded;
      case SearchResultType.workflow:
        return Icons.account_tree_rounded;
      case SearchResultType.glossary:
        return Icons.menu_book_rounded;
      case SearchResultType.futureTrend:
        return Icons.insights_rounded;
      case SearchResultType.source:
        return Icons.link_rounded;
    }
  }
}

/// 통합 검색 결과 항목을 나타내는 뷰 모델.
class SearchResult {
  const SearchResult({
    required this.type,
    required this.id,
    required this.title,
    required this.snippet,
    required this.routePath,
    this.status = ContentStatus.unknown,
    this.verifiedAt = '',
  });

  final SearchResultType type;
  final String id;
  final String title;
  final String snippet;
  final String routePath;

  /// 검증 상태(가능한 경우). 필터 칩과 상태 배지 표시에 사용한다.
  final ContentStatus status;

  /// 마지막 검증일(`yyyy-MM-dd`, 가능한 경우). 최근 검증 순 정렬에 사용한다.
  final String verifiedAt;
}
