import '../utils/json_helpers.dart';
import 'content_status.dart';

/// 워크플로 내 개별 실행 단계.
class WorkflowStep {
  const WorkflowStep({
    required this.stepNumber,
    required this.action,
    required this.tools,
    required this.inputExample,
    required this.expectedResult,
    required this.humanReviewPoints,
  });

  final int stepNumber;
  final String action;
  final List<String> tools;
  final String inputExample;
  final String expectedResult;
  final List<String> humanReviewPoints;

  factory WorkflowStep.fromJson(Map<String, dynamic> json) {
    return WorkflowStep(
      stepNumber: asInt(json['stepNumber']),
      action: asString(json['action']),
      tools: asStringList(json['tools']),
      inputExample: asString(json['inputExample']),
      expectedResult: asString(json['expectedResult']),
      humanReviewPoints: asStringList(json['humanReviewPoints']),
    );
  }
}

/// `assets/data/workflows.json`의 개별 실전 워크플로 항목.
class Workflow {
  const Workflow({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    required this.objective,
    required this.prerequisites,
    required this.recommendedToolIds,
    required this.steps,
    required this.humanReviewPoints,
    required this.privacyWarnings,
    required this.expectedOutput,
    required this.difficulty,
    required this.estimatedTimeNote,
    required this.relatedToolIds,
    required this.sourceIds,
    required this.verifiedAt,
    required this.status,
  });

  final String id;
  final String title;
  final String summary;
  final String category;
  final String objective;
  final List<String> prerequisites;
  final List<String> recommendedToolIds;
  final List<WorkflowStep> steps;
  final List<String> humanReviewPoints;
  final List<String> privacyWarnings;
  final String expectedOutput;
  final String difficulty;
  final String estimatedTimeNote;
  final List<String> relatedToolIds;
  final List<String> sourceIds;
  final String verifiedAt;
  final ContentStatus status;

  factory Workflow.fromJson(Map<String, dynamic> json) {
    return Workflow(
      id: asString(json['id']),
      title: asString(json['title']),
      summary: asString(json['summary']),
      category: asString(json['category']),
      objective: asString(json['objective']),
      prerequisites: asStringList(json['prerequisites']),
      recommendedToolIds: asStringList(json['recommendedTools']),
      steps: asMapList(json['steps']).map(WorkflowStep.fromJson).toList(),
      humanReviewPoints: asStringList(json['humanReviewPoints']),
      privacyWarnings: asStringList(json['privacyWarnings']),
      expectedOutput: asString(json['expectedOutput']),
      difficulty: asString(json['difficulty']),
      estimatedTimeNote: asString(json['estimatedTimeNote']),
      relatedToolIds: asStringList(json['relatedToolIds']),
      sourceIds: asStringList(json['sourceIds']),
      verifiedAt: asString(json['verifiedAt']),
      status: ContentStatus.fromJson(asStringOrNull(json['status'])),
    );
  }
}

/// 난이도 코드를 한국어 라벨로 변환한다.
String difficultyLabel(String difficulty) {
  const map = {'beginner': '초급', 'intermediate': '중급', 'advanced': '고급'};
  return map[difficulty] ?? difficulty;
}
