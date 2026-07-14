import 'package:flutter/material.dart';

import 'route_paths.dart';

/// 사이드바/드로어에 표시되는 메뉴 항목 데이터 모델.
class MenuItem {
  const MenuItem({
    required this.title,
    required this.route,
    required this.icon,
    required this.description,
  });

  final String title;
  final String route;
  final IconData icon;
  final String description;
}

/// 앱 전체 18개 메뉴 항목 정의.
///
/// 순서는 사이드바에 표시되는 순서와 동일하다. `/favorites`는 헤더에서
/// 접근하는 별도 경로이므로 이 목록에는 포함하지 않는다.
class MenuItems {
  MenuItems._();

  static const List<MenuItem> all = [
    MenuItem(
      title: 'AI스토리 홈',
      route: RoutePaths.home,
      icon: Icons.home_rounded,
      description: '소통AI스토리 서비스의 시작 페이지입니다.',
    ),
    MenuItem(
      title: 'AI 역사 연대표',
      route: RoutePaths.timeline,
      icon: Icons.timeline_rounded,
      description: '1950년부터 현재까지 AI 역사의 주요 사건을 시간순으로 살펴봅니다.',
    ),
    MenuItem(
      title: '시대별 AI 변천사',
      route: RoutePaths.eras,
      icon: Icons.history_edu_rounded,
      description: 'AI 발전을 여러 시대로 구분해 각 시기의 특징과 전환점을 설명합니다.',
    ),
    MenuItem(
      title: 'AI 핵심 개념',
      route: RoutePaths.concepts,
      icon: Icons.psychology_rounded,
      description: '머신러닝, 딥러닝, LLM 등 AI의 핵심 개념을 쉽게 풀어 설명합니다.',
    ),
    MenuItem(
      title: 'AI 툴 탐색',
      route: RoutePaths.tools,
      icon: Icons.explore_rounded,
      description: '다양한 AI 도구를 카테고리와 조건별로 찾아봅니다.',
    ),
    MenuItem(
      title: '분야별 AI 활용',
      route: RoutePaths.useCases,
      icon: Icons.business_center_rounded,
      description: '업종·직무별로 AI를 실제로 활용하는 사례를 소개합니다.',
    ),
    MenuItem(
      title: '인기·주목 AI',
      route: RoutePaths.popularAi,
      icon: Icons.trending_up_rounded,
      description: '현재 가장 널리 쓰이고 주목받는 AI 도구를 모았습니다.',
    ),
    MenuItem(
      title: '숨은 보석 AI',
      route: RoutePaths.hiddenGems,
      icon: Icons.diamond_rounded,
      description: '잘 알려지지 않았지만 유용한 AI 도구를 소개합니다.',
    ),
    MenuItem(
      title: 'AI 툴 비교',
      route: RoutePaths.toolCompare,
      icon: Icons.compare_arrows_rounded,
      description: '최대 3개의 AI 도구를 나란히 비교해 봅니다.',
    ),
    MenuItem(
      title: '실전 AI 워크플로',
      route: RoutePaths.workflows,
      icon: Icons.account_tree_rounded,
      description: '실제 업무에 AI를 단계별로 적용하는 워크플로를 안내합니다.',
    ),
    MenuItem(
      title: '대한민국과 AI',
      route: RoutePaths.koreaAi,
      icon: Icons.flag_rounded,
      description: '한국의 AI 정책과 국내 기업의 AI 서비스를 다룹니다.',
    ),
    MenuItem(
      title: '산업·농업 AI',
      route: RoutePaths.industryAi,
      icon: Icons.factory_rounded,
      description: '제조·농업 등 다양한 산업 분야의 AI 활용 현황을 소개합니다.',
    ),
    MenuItem(
      title: 'AI 개발자 공간',
      route: RoutePaths.developer,
      icon: Icons.code_rounded,
      description: 'API, 프롬프트 엔지니어링, RAG 등 개발자를 위한 정보를 제공합니다.',
    ),
    MenuItem(
      title: '안전·윤리·저작권',
      route: RoutePaths.safety,
      icon: Icons.shield_rounded,
      description: 'AI 사용 시 유의해야 할 안전, 윤리, 저작권 이슈를 다룹니다.',
    ),
    MenuItem(
      title: 'AI 미래 전망',
      route: RoutePaths.future,
      icon: Icons.insights_rounded,
      description: '앞으로의 AI 발전 방향과 준비할 점을 전망합니다.',
    ),
    MenuItem(
      title: 'AI 용어사전',
      route: RoutePaths.glossary,
      icon: Icons.menu_book_rounded,
      description: 'AI 관련 용어를 한글·영문으로 찾아볼 수 있습니다.',
    ),
    MenuItem(
      title: '출처·검증센터',
      route: RoutePaths.sources,
      icon: Icons.verified_rounded,
      description: '콘텐츠에 사용된 출처와 검증 상태를 확인합니다.',
    ),
    MenuItem(
      title: '소통웨어 소개',
      route: RoutePaths.about,
      icon: Icons.info_rounded,
      description: '이 서비스를 만든 소통웨어를 소개합니다.',
    ),
  ];
}
