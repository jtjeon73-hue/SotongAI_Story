import 'package:flutter/material.dart';

import '../core/repositories/content_repository.dart';
import '../core/storage/favorites_storage.dart';

/// [ContentRepository]와 [FavoritesStorage]를 하위 위젯 트리 전체에
/// 전달하는 InheritedWidget.
///
/// 두 의존성 모두 `main()`에서 로드가 완료된 뒤 생성되므로, 이 위젯이
/// 트리에 존재하는 동안에는 항상 유효한 인스턴스를 갖는다.
class AppScope extends InheritedWidget {
  const AppScope({
    required this.repository,
    required this.favorites,
    required super.child,
    super.key,
  });

  final ContentRepository repository;
  final FavoritesStorage favorites;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope를 찾을 수 없습니다. 위젯 트리를 확인하세요.');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      repository != oldWidget.repository || favorites != oldWidget.favorites;
}
