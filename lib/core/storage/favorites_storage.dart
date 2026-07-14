import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// 즐겨찾기 콘텐츠 카테고리.
enum FavoriteCategory { timeline, tools, workflows, concepts }

extension FavoriteCategoryX on FavoriteCategory {
  String get storageKey {
    switch (this) {
      case FavoriteCategory.timeline:
        return AppConstants.favTimeline;
      case FavoriteCategory.tools:
        return AppConstants.favTools;
      case FavoriteCategory.workflows:
        return AppConstants.favWorkflows;
      case FavoriteCategory.concepts:
        return AppConstants.favConcepts;
    }
  }

  String get label {
    switch (this) {
      case FavoriteCategory.timeline:
        return '연대표';
      case FavoriteCategory.tools:
        return 'AI 툴';
      case FavoriteCategory.workflows:
        return '워크플로';
      case FavoriteCategory.concepts:
        return '핵심 개념';
    }
  }
}

/// `shared_preferences` 기반 즐겨찾기 저장소.
///
/// 카테고리별로 ID 목록을 문자열 셋(Set)으로 저장한다. 위젯이 즐겨찾기
/// 상태 변화를 즉시 반영할 수 있도록 [ValueNotifier] 대신 간단한
/// 리스너 콜백 패턴을 사용한다.
class FavoritesStorage {
  FavoritesStorage._(this._prefs);

  final SharedPreferences _prefs;

  final List<void Function()> _listeners = [];

  static Future<FavoritesStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return FavoritesStorage._(prefs);
  }

  void addListener(void Function() listener) => _listeners.add(listener);

  void removeListener(void Function() listener) => _listeners.remove(listener);

  void _notify() {
    for (final l in List.of(_listeners)) {
      l();
    }
  }

  Set<String> _idsOf(FavoriteCategory category) {
    return (_prefs.getStringList(category.storageKey) ?? const []).toSet();
  }

  /// [category] 내 즐겨찾기 ID 목록을 반환한다.
  List<String> idsOf(FavoriteCategory category) => _idsOf(category).toList();

  /// [id]가 [category]에서 즐겨찾기되어 있는지 확인한다.
  bool isFavorite(FavoriteCategory category, String id) {
    return _idsOf(category).contains(id);
  }

  /// 즐겨찾기 상태를 토글하고 결과(토글 후 상태)를 반환한다.
  Future<bool> toggle(FavoriteCategory category, String id) async {
    final ids = _idsOf(category);
    final willBeFavorite = !ids.contains(id);
    if (willBeFavorite) {
      ids.add(id);
    } else {
      ids.remove(id);
    }
    await _prefs.setStringList(category.storageKey, ids.toList());
    _notify();
    return willBeFavorite;
  }

  /// 전체 카테고리에 즐겨찾기된 항목이 하나라도 있는지 여부.
  bool get hasAnyFavorite {
    for (final category in FavoriteCategory.values) {
      if (_idsOf(category).isNotEmpty) return true;
    }
    return false;
  }
}
