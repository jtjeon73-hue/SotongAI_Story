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

/// 사이드바에 표시되는 메뉴 그룹(카테고리) 데이터 모델.
class MenuGroup {
  const MenuGroup({required this.title, required this.items});

  /// 사이드바가 펼쳐진 상태에서만 표시되는 그룹 제목.
  final String title;
  final List<MenuItem> items;
}

/// 앱 전체 메뉴를 4개 그룹으로 구성한 정의.
///
/// 그룹/항목 순서는 사이드바에 표시되는 순서와 동일하다. `/favorites`는
/// 헤더에서 접근하는 별도 경로이므로 이 목록에는 포함하지 않는다.
class MenuItems {
  MenuItems._();

  static const MenuItem home = MenuItem(
    title: 'AI스토리 홈',
    route: RoutePaths.home,
    icon: Icons.home_rounded,
    description: '소통AI스토리 서비스의 시작 페이지입니다.',
  );

  static const MenuItem timeline = MenuItem(
    title: 'AI 역사 연대표',
    route: RoutePaths.timeline,
    icon: Icons.timeline_rounded,
    description: '1950년부터 현재까지 AI 역사의 주요 사건을 시간순으로 살펴봅니다.',
  );

  static const MenuItem eras = MenuItem(
    title: '시대별 AI 변천사',
    route: RoutePaths.eras,
    icon: Icons.history_edu_rounded,
    description: 'AI 발전을 여러 시대로 구분해 각 시기의 특징과 전환점을 설명합니다.',
  );

  static const MenuItem concepts = MenuItem(
    title: 'AI 핵심 개념',
    route: RoutePaths.concepts,
    icon: Icons.psychology_rounded,
    description: '머신러닝, 딥러닝, LLM 등 AI의 핵심 개념을 쉽게 풀어 설명합니다.',
  );

  static const MenuItem glossary = MenuItem(
    title: 'AI 용어사전',
    route: RoutePaths.glossary,
    icon: Icons.menu_book_rounded,
    description: 'AI 관련 용어를 한글·영문으로 찾아볼 수 있습니다.',
  );

  static const MenuItem tools = MenuItem(
    title: 'AI 툴 탐색',
    route: RoutePaths.tools,
    icon: Icons.explore_rounded,
    description: '다양한 AI 도구를 카테고리와 조건별로 찾아봅니다.',
  );

  static const MenuItem popularAi = MenuItem(
    title: '인기·주목 AI',
    route: RoutePaths.popularAi,
    icon: Icons.trending_up_rounded,
    description: '현재 가장 널리 쓰이고 주목받는 AI 도구를 모았습니다.',
  );

  static const MenuItem hiddenGems = MenuItem(
    title: '숨은 보석 AI',
    route: RoutePaths.hiddenGems,
    icon: Icons.diamond_rounded,
    description: '잘 알려지지 않았지만 유용한 AI 도구를 소개합니다.',
  );

  static const MenuItem toolCompare = MenuItem(
    title: 'AI 툴 비교',
    route: RoutePaths.toolCompare,
    icon: Icons.compare_arrows_rounded,
    description: '최대 3개의 AI 도구를 나란히 비교해 봅니다.',
  );

  static const MenuItem useCases = MenuItem(
    title: '분야별 AI 활용',
    route: RoutePaths.useCases,
    icon: Icons.business_center_rounded,
    description: '업종·직무별로 AI를 실제로 활용하는 사례를 소개합니다.',
  );

  static const MenuItem workflows = MenuItem(
    title: '실전 AI 워크플로',
    route: RoutePaths.workflows,
    icon: Icons.account_tree_rounded,
    description: '실제 업무에 AI를 단계별로 적용하는 워크플로를 안내합니다.',
  );

  static const MenuItem koreaAi = MenuItem(
    title: '대한민국과 AI',
    route: RoutePaths.koreaAi,
    icon: Icons.flag_rounded,
    description: '한국의 AI 정책과 국내 기업의 AI 서비스를 다룹니다.',
  );

  static const MenuItem industryAi = MenuItem(
    title: '산업·농업 AI',
    route: RoutePaths.industryAi,
    icon: Icons.factory_rounded,
    description: '제조·농업 등 다양한 산업 분야의 AI 활용 현황을 소개합니다.',
  );

  static const MenuItem developer = MenuItem(
    title: 'AI 개발자 공간',
    route: RoutePaths.developer,
    icon: Icons.code_rounded,
    description: 'API, 프롬프트 엔지니어링, RAG 등 개발자를 위한 정보를 제공합니다.',
  );

  static const MenuItem safety = MenuItem(
    title: '안전·윤리·저작권',
    route: RoutePaths.safety,
    icon: Icons.shield_rounded,
    description: 'AI 사용 시 유의해야 할 안전, 윤리, 저작권 이슈를 다룹니다.',
  );

  static const MenuItem future = MenuItem(
    title: 'AI 미래 전망',
    route: RoutePaths.future,
    icon: Icons.insights_rounded,
    description: '앞으로의 AI 발전 방향과 준비할 점을 전망합니다.',
  );

  static const MenuItem sources = MenuItem(
    title: '출처·검증센터',
    route: RoutePaths.sources,
    icon: Icons.verified_rounded,
    description: '콘텐츠에 사용된 출처와 검증 상태를 확인합니다.',
  );

  static const MenuItem about = MenuItem(
    title: '소통웨어 소개',
    route: RoutePaths.about,
    icon: Icons.info_rounded,
    description: '이 서비스를 만든 소통웨어를 소개합니다.',
  );

  /// A. AI 이해하기: AI의 역사·개념을 배우는 입문 그룹.
  static const MenuGroup groupUnderstanding = MenuGroup(
    title: 'AI 이해하기',
    items: [home, timeline, eras, concepts, glossary],
  );

  /// B. AI 도구와 활용: AI 도구 탐색·비교·업무 적용 그룹.
  static const MenuGroup groupToolsAndUsage = MenuGroup(
    title: 'AI 도구와 활용',
    items: [tools, popularAi, hiddenGems, toolCompare, useCases, workflows],
  );

  /// C. 산업과 사회: 산업·사회적 맥락에서 AI를 다루는 그룹.
  static const MenuGroup groupIndustryAndSociety = MenuGroup(
    title: '산업과 사회',
    items: [koreaAi, industryAi, developer, safety, future],
  );

  /// D. 신뢰와 운영: 출처 검증과 서비스 운영 정보를 다루는 그룹.
  static const MenuGroup groupTrustAndOperations = MenuGroup(
    title: '신뢰와 운영',
    items: [sources, about],
  );

  /// 사이드바에 표시되는 4개 메뉴 그룹(순서 고정).
  static const List<MenuGroup> groups = [
    groupUnderstanding,
    groupToolsAndUsage,
    groupIndustryAndSociety,
    groupTrustAndOperations,
  ];

  /// 모든 메뉴 항목을 그룹 순서대로 펼친 평탄화 목록(기존 호환용).
  static final List<MenuItem> all = groups.expand((g) => g.items).toList();
}
