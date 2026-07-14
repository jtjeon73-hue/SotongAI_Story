import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/route_paths.dart';
import '../features/about/about_page.dart';
import '../features/concepts/concept_detail_page.dart';
import '../features/concepts/concepts_page.dart';
import '../features/developer/developer_page.dart';
import '../features/eras/era_detail_page.dart';
import '../features/eras/eras_page.dart';
import '../features/favorites/favorites_page.dart';
import '../features/future/future_page.dart';
import '../features/glossary/glossary_page.dart';
import '../features/hidden_gems/hidden_gems_page.dart';
import '../features/home/home_page.dart';
import '../features/industry_ai/industry_ai_page.dart';
import '../features/korea_ai/korea_ai_page.dart';
import '../features/not_found/not_found_page.dart';
import '../features/popular_ai/popular_ai_page.dart';
import '../features/safety/safety_page.dart';
import '../features/search/search_page.dart';
import '../features/sources/sources_page.dart';
import '../features/timeline/timeline_detail_page.dart';
import '../features/timeline/timeline_page.dart';
import '../features/tool_compare/tool_compare_page.dart';
import '../features/tools/tool_detail_page.dart';
import '../features/tools/tools_page.dart';
import '../features/use_cases/use_case_detail_page.dart';
import '../features/use_cases/use_cases_page.dart';
import '../features/workflows/workflow_detail_page.dart';
import '../features/workflows/workflows_page.dart';
import 'app_shell.dart';

/// 앱 전역 go_router 설정.
///
/// 모든 화면은 [AppShell]을 통해 사이드바/드로어와 함께 렌더링되며,
/// 상세 페이지 경로는 `:id` 파라미터를 사용해 고유 URL을 갖는다.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: RoutePaths.home,
    errorBuilder: (context, state) => const Scaffold(body: NotFoundPage()),
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(currentPath: state.uri.path, child: child);
        },
        routes: [
          GoRoute(
            path: RoutePaths.home,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: RoutePaths.timeline,
            builder: (context, state) => const TimelinePage(),
          ),
          GoRoute(
            path: RoutePaths.timelineDetail,
            builder: (context, state) =>
                TimelineDetailPage(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: RoutePaths.eras,
            builder: (context, state) => const ErasPage(),
          ),
          GoRoute(
            path: RoutePaths.erasDetail,
            builder: (context, state) =>
                EraDetailPage(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: RoutePaths.concepts,
            builder: (context, state) => const ConceptsPage(),
          ),
          GoRoute(
            path: RoutePaths.conceptsDetail,
            builder: (context, state) =>
                ConceptDetailPage(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: RoutePaths.tools,
            builder: (context, state) => const ToolsPage(),
          ),
          GoRoute(
            path: RoutePaths.toolsDetail,
            builder: (context, state) =>
                ToolDetailPage(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: RoutePaths.toolCompare,
            builder: (context, state) => const ToolComparePage(),
          ),
          GoRoute(
            path: RoutePaths.useCases,
            builder: (context, state) => const UseCasesPage(),
          ),
          GoRoute(
            path: RoutePaths.useCasesDetail,
            builder: (context, state) =>
                UseCaseDetailPage(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: RoutePaths.popularAi,
            builder: (context, state) => const PopularAiPage(),
          ),
          GoRoute(
            path: RoutePaths.hiddenGems,
            builder: (context, state) => const HiddenGemsPage(),
          ),
          GoRoute(
            path: RoutePaths.workflows,
            builder: (context, state) => const WorkflowsPage(),
          ),
          GoRoute(
            path: RoutePaths.workflowsDetail,
            builder: (context, state) =>
                WorkflowDetailPage(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: RoutePaths.koreaAi,
            builder: (context, state) => const KoreaAiPage(),
          ),
          GoRoute(
            path: RoutePaths.industryAi,
            builder: (context, state) => const IndustryAiPage(),
          ),
          GoRoute(
            path: RoutePaths.developer,
            builder: (context, state) => const DeveloperPage(),
          ),
          GoRoute(
            path: RoutePaths.safety,
            builder: (context, state) => const SafetyPage(),
          ),
          GoRoute(
            path: RoutePaths.future,
            builder: (context, state) => const FuturePage(),
          ),
          GoRoute(
            path: RoutePaths.glossary,
            builder: (context, state) => const GlossaryPage(),
          ),
          GoRoute(
            path: RoutePaths.sources,
            builder: (context, state) => const SourcesPage(),
          ),
          GoRoute(
            path: RoutePaths.about,
            builder: (context, state) => const AboutPage(),
          ),
          GoRoute(
            path: RoutePaths.favorites,
            builder: (context, state) => const FavoritesPage(),
          ),
          GoRoute(
            path: RoutePaths.search,
            builder: (context, state) =>
                SearchPage(initialQuery: state.uri.queryParameters['q'] ?? ''),
          ),
        ],
      ),
    ],
  );
}
