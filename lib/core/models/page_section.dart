import '../utils/json_helpers.dart';

/// 한국 AI, 산업·농업 AI, 개발자 공간, 안전·윤리 등 섹션 기반 페이지에서
/// 공통으로 사용하는 콘텐츠 블록 모델.
///
/// `korea_ai.json`/`industry_ai.json`은 `body` 필드를 사용하고,
/// `developer.json`/`safety.json`은 `summary`+`content`+`codeExample`+
/// `warnings` 필드를 사용하므로, 두 스키마를 모두 흡수할 수 있도록
/// 필드를 nullable하게 설계했다.
class PageSection {
  const PageSection({
    required this.id,
    required this.title,
    this.body,
    this.summary,
    this.content,
    this.codeExample,
    required this.warnings,
    required this.sourceIds,
    required this.verifiedAt,
  });

  final String id;
  final String title;
  final String? body;
  final String? summary;
  final String? content;
  final String? codeExample;
  final List<String> warnings;
  final List<String> sourceIds;
  final String verifiedAt;

  /// 본문으로 표시할 텍스트. `body`가 있으면 그것을, 없으면 `content`를 사용.
  String get displayBody => body ?? content ?? '';

  factory PageSection.fromJson(Map<String, dynamic> json) {
    return PageSection(
      id: asString(json['id']),
      title: asString(json['title']),
      body: asStringOrNull(json['body']),
      summary: asStringOrNull(json['summary']),
      content: asStringOrNull(json['content']),
      codeExample: asStringOrNull(json['codeExample']),
      warnings: asStringList(json['warnings']),
      sourceIds: asStringList(json['sourceIds']),
      verifiedAt: asString(json['verifiedAt']),
    );
  }
}
