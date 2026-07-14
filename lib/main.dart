import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_scope.dart';
import 'core/repositories/content_repository.dart';
import 'core/storage/favorites_storage.dart';
import 'shared/theme/app_colors.dart';
import 'shared/theme/app_text_styles.dart';
import 'shared/widgets/error_state.dart';
import 'shared/widgets/loading_view.dart';

void main() {
  runApp(const _BootstrapApp());
}

/// 앱 시작 시 [ContentRepository]와 [FavoritesStorage]를 비동기로 준비하는
/// 부트스트랩 위젯.
///
/// JSON 로딩이 끝나기 전에는 로딩 화면을, 실패하면 재시도 가능한 에러 화면을
/// 보여주고, 성공하면 [AppScope]로 감싼 실제 앱([SotongAiStoryApp])을 렌더링한다.
class _BootstrapApp extends StatefulWidget {
  const _BootstrapApp();

  @override
  State<_BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<_BootstrapApp> {
  late Future<_Bootstrapped> _future;

  @override
  void initState() {
    super.initState();
    _future = _bootstrap();
  }

  Future<_Bootstrapped> _bootstrap() async {
    final repository = ContentRepository();
    final favorites = await FavoritesStorage.create();
    await repository.loadAll();
    return _Bootstrapped(repository: repository, favorites: favorites);
  }

  void _retry() {
    setState(() {
      _future = _bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: FutureBuilder<_Bootstrapped>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: LoadingView(message: '소통AI스토리를 준비하는 중입니다...'),
            );
          }
          if (snapshot.hasError) {
            return Scaffold(
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '소통AI스토리',
                        style: AppTextStyles.h1.copyWith(color: AppColors.navy),
                      ),
                      const SizedBox(height: 24),
                      ErrorStateView(
                        title: '콘텐츠를 불러오지 못했습니다',
                        message: '데이터를 불러오는 중 문제가 발생했습니다: ${snapshot.error}',
                        onRetry: _retry,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          final data = snapshot.data!;
          return AppScope(
            repository: data.repository,
            favorites: data.favorites,
            child: const SotongAiStoryApp(),
          );
        },
      ),
    );
  }
}

class _Bootstrapped {
  const _Bootstrapped({required this.repository, required this.favorites});

  final ContentRepository repository;
  final FavoritesStorage favorites;
}
