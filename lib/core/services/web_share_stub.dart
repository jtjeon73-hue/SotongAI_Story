/// 네이티브(비웹) 플랫폼용 스텁 구현.
///
/// Web Share API를 사용할 수 없는 플랫폼에서는 항상 실패를 반환해
/// 호출부가 클립보드 복사 방식으로 대체(fallback)하도록 한다.
Future<bool> tryWebShare({
  required String title,
  required String url,
  String? text,
}) async {
  return false;
}
