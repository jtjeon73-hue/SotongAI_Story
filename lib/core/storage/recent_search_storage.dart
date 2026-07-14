import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// 최근 검색어를 기기 로컬(`shared_preferences`)에만 저장하는 저장소.
///
/// 서버로 전송되지 않으며, 사용자가 언제든 [clear]로 전체 삭제할 수 있다.
/// 가장 최근 검색어가 목록 맨 앞에 오도록 유지하고, 중복 검색어는 최신
/// 위치로 옮긴 뒤 [AppConstants.maxRecentSearches]개까지만 보관한다.
class RecentSearchStorage {
  RecentSearchStorage._(this._prefs);

  final SharedPreferences _prefs;

  static Future<RecentSearchStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return RecentSearchStorage._(prefs);
  }

  List<String> get queries =>
      _prefs.getStringList(AppConstants.recentSearchesKey) ?? const [];

  Future<void> add(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final updated = [
      trimmed,
      ...queries.where((q) => q.toLowerCase() != trimmed.toLowerCase()),
    ];
    final limited = updated.take(AppConstants.maxRecentSearches).toList();
    await _prefs.setStringList(AppConstants.recentSearchesKey, limited);
  }

  Future<void> remove(String query) async {
    final updated = queries.where((q) => q != query).toList();
    await _prefs.setStringList(AppConstants.recentSearchesKey, updated);
  }

  Future<void> clear() async {
    await _prefs.remove(AppConstants.recentSearchesKey);
  }
}
