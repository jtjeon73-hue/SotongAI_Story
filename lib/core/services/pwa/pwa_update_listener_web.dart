import 'package:web/web.dart' as web;

/// 새 서비스 워커가 활성화되어 페이지 컨트롤이 바뀔 때(`controllerchange`)
/// [onUpdateAvailable]을 호출한다.
///
/// Flutter 웹은 빌드마다 내용이 달라지는 `flutter_service_worker.js`를
/// 자동으로 등록·관리한다. 새 배포판이 설치되어 활성 서비스 워커가
/// 교체되면 브라우저가 `controllerchange` 이벤트를 발생시키므로, 이를
/// "새 버전이 배포됨"의 신호로 사용한다. 별도의 폴링이나 커스텀 서비스
/// 워커 수정 없이도 동작하는 가장 단순한 방법이다.
void listenForServiceWorkerUpdate(void Function() onUpdateAvailable) {
  try {
    final serviceWorker = web.window.navigator.serviceWorker;
    const provider = web.EventStreamProvider<web.Event>('controllerchange');
    provider.forTarget(serviceWorker).listen((_) => onUpdateAvailable());
  } catch (_) {
    // 서비스 워커를 지원하지 않는 브라우저에서는 조용히 무시한다.
  }
}

/// 사용자가 "새로고침"을 눌렀을 때 페이지를 다시 로드한다.
void reloadPage() {
  web.window.location.reload();
}
