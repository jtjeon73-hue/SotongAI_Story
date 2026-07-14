import 'dart:js_interop';

/// 브라우저의 `navigator.share` / `navigator.canShare`에 대한 최소 JS 인터롭.
@JS('navigator.canShare')
external bool _canShare();

@JS('navigator.share')
external JSPromise _share(JSAny options);

/// 웹 플랫폼에서 Web Share API를 시도한다.
///
/// 브라우저가 지원하지 않거나 사용자가 공유를 취소하는 등의 이유로 실패하면
/// false를 반환해 호출부가 클립보드 복사 방식으로 대체하도록 한다.
Future<bool> tryWebShare({
  required String title,
  required String url,
  String? text,
}) async {
  try {
    if (!_canShare()) return false;
    final options = <String, String>{
      'title': title,
      'text': ?text,
      'url': url,
    }.jsify();
    if (options == null) return false;
    await _share(options).toDart;
    return true;
  } catch (_) {
    return false;
  }
}
