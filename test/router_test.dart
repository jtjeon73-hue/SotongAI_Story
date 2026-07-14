import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sotong_ai_story/core/constants/route_paths.dart';

/// [RoutePaths]에 정의된 모든 경로가 go_router에서 실제로 해석되는지
/// 확인하는 테스트.
///
/// 실제 페이지 위젯은 [ContentRepository] 등 앱 전역 상태가 필요하므로,
/// 여기서는 동일한 경로 구조를 재현한 최소 go_router 설정으로 라우팅
/// 동작(경로 매칭, path parameter 추출)만 검증한다.
void main() {
  late GoRouter router;

  setUp(() {
    router = GoRouter(
      initialLocation: RoutePaths.home,
      routes: [
        GoRoute(
          path: RoutePaths.home,
          builder: (c, s) => const _Placeholder('home'),
        ),
        GoRoute(
          path: RoutePaths.timeline,
          builder: (c, s) => const _Placeholder('timeline'),
        ),
        GoRoute(
          path: RoutePaths.timelineDetail,
          builder: (c, s) =>
              _Placeholder('timeline-detail:${s.pathParameters['id']}'),
        ),
        GoRoute(
          path: RoutePaths.eras,
          builder: (c, s) => const _Placeholder('eras'),
        ),
        GoRoute(
          path: RoutePaths.erasDetail,
          builder: (c, s) =>
              _Placeholder('eras-detail:${s.pathParameters['id']}'),
        ),
        GoRoute(
          path: RoutePaths.concepts,
          builder: (c, s) => const _Placeholder('concepts'),
        ),
        GoRoute(
          path: RoutePaths.conceptsDetail,
          builder: (c, s) =>
              _Placeholder('concepts-detail:${s.pathParameters['id']}'),
        ),
        GoRoute(
          path: RoutePaths.tools,
          builder: (c, s) => const _Placeholder('tools'),
        ),
        GoRoute(
          path: RoutePaths.toolsDetail,
          builder: (c, s) =>
              _Placeholder('tools-detail:${s.pathParameters['id']}'),
        ),
        GoRoute(
          path: RoutePaths.toolCompare,
          builder: (c, s) => const _Placeholder('tool-compare'),
        ),
        GoRoute(
          path: RoutePaths.useCases,
          builder: (c, s) => const _Placeholder('use-cases'),
        ),
        GoRoute(
          path: RoutePaths.useCasesDetail,
          builder: (c, s) =>
              _Placeholder('use-cases-detail:${s.pathParameters['id']}'),
        ),
        GoRoute(
          path: RoutePaths.popularAi,
          builder: (c, s) => const _Placeholder('popular-ai'),
        ),
        GoRoute(
          path: RoutePaths.hiddenGems,
          builder: (c, s) => const _Placeholder('hidden-gems'),
        ),
        GoRoute(
          path: RoutePaths.workflows,
          builder: (c, s) => const _Placeholder('workflows'),
        ),
        GoRoute(
          path: RoutePaths.workflowsDetail,
          builder: (c, s) =>
              _Placeholder('workflows-detail:${s.pathParameters['id']}'),
        ),
        GoRoute(
          path: RoutePaths.koreaAi,
          builder: (c, s) => const _Placeholder('korea-ai'),
        ),
        GoRoute(
          path: RoutePaths.industryAi,
          builder: (c, s) => const _Placeholder('industry-ai'),
        ),
        GoRoute(
          path: RoutePaths.developer,
          builder: (c, s) => const _Placeholder('developer'),
        ),
        GoRoute(
          path: RoutePaths.safety,
          builder: (c, s) => const _Placeholder('safety'),
        ),
        GoRoute(
          path: RoutePaths.future,
          builder: (c, s) => const _Placeholder('future'),
        ),
        GoRoute(
          path: RoutePaths.glossary,
          builder: (c, s) => const _Placeholder('glossary'),
        ),
        GoRoute(
          path: RoutePaths.sources,
          builder: (c, s) => const _Placeholder('sources'),
        ),
        GoRoute(
          path: RoutePaths.about,
          builder: (c, s) => const _Placeholder('about'),
        ),
        GoRoute(
          path: RoutePaths.favorites,
          builder: (c, s) => const _Placeholder('favorites'),
        ),
        GoRoute(
          path: RoutePaths.search,
          builder: (c, s) => const _Placeholder('search'),
        ),
      ],
      errorBuilder: (c, s) => const _Placeholder('not-found'),
    );
  });

  Future<void> pumpAt(WidgetTester tester, String location) async {
    router.go(location);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  testWidgets('홈 경로(/)가 해석된다', (tester) async {
    await pumpAt(tester, RoutePaths.home);
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('연대표 상세 경로가 id 파라미터를 추출한다', (tester) async {
    await pumpAt(tester, RoutePaths.timelineDetailOf('tl-alphago'));
    expect(find.text('timeline-detail:tl-alphago'), findsOneWidget);
  });

  testWidgets('도구 상세 경로가 id 파라미터를 추출한다', (tester) async {
    await pumpAt(tester, RoutePaths.toolsDetailOf('tool-chatgpt'));
    expect(find.text('tools-detail:tool-chatgpt'), findsOneWidget);
  });

  testWidgets('워크플로 상세 경로가 id 파라미터를 추출한다', (tester) async {
    await pumpAt(tester, RoutePaths.workflowsDetailOf('wf-report'));
    expect(find.text('workflows-detail:wf-report'), findsOneWidget);
  });

  testWidgets('존재하지 않는 경로는 errorBuilder로 처리된다', (tester) async {
    await pumpAt(tester, '/no-such-page');
    expect(find.text('not-found'), findsOneWidget);
  });

  for (final path in [
    RoutePaths.eras,
    RoutePaths.concepts,
    RoutePaths.tools,
    RoutePaths.toolCompare,
    RoutePaths.useCases,
    RoutePaths.popularAi,
    RoutePaths.hiddenGems,
    RoutePaths.workflows,
    RoutePaths.koreaAi,
    RoutePaths.industryAi,
    RoutePaths.developer,
    RoutePaths.safety,
    RoutePaths.future,
    RoutePaths.glossary,
    RoutePaths.sources,
    RoutePaths.about,
    RoutePaths.favorites,
    RoutePaths.search,
  ]) {
    testWidgets('$path 경로가 오류 없이 해석된다', (tester) async {
      await pumpAt(tester, path);
      expect(find.text('not-found'), findsNothing);
    });
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text(label));
  }
}
