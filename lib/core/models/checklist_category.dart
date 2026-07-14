import '../utils/json_helpers.dart';

/// 체크리스트 안의 개별 확인 항목.
class ChecklistItem {
  const ChecklistItem({required this.id, required this.text});

  final String id;
  final String text;

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(id: asString(json['id']), text: asString(json['text']));
  }
}

/// `assets/data/ai_adoption_checklists.json`의 체크리스트 묶음 하나
/// (예: "공공기관 AI 도입 전 확인사항").
///
/// 여기 담긴 항목들은 일반적으로 널리 권고되는 점검 사항을 정리한 참고
/// 자료이며, 특정 법령이나 정부 기관의 공식 가이드라인을 대체하지 않는다.
/// 실제 도입 시에는 관련 법령과 소관 부처의 최신 지침을 반드시 확인해야
/// 한다(각 카테고리의 [disclaimer] 참고).
class ChecklistCategory {
  const ChecklistCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.disclaimer,
    required this.items,
    required this.sourceIds,
  });

  final String id;
  final String title;
  final String description;
  final String disclaimer;
  final List<ChecklistItem> items;
  final List<String> sourceIds;

  factory ChecklistCategory.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List? ?? [])
        .map((e) => ChecklistItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return ChecklistCategory(
      id: asString(json['id']),
      title: asString(json['title']),
      description: asString(json['description']),
      disclaimer: asString(json['disclaimer']),
      items: items,
      sourceIds: asStringList(json['sourceIds']),
    );
  }
}
