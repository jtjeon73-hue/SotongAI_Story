import 'pwa/pwa_update_listener_stub.dart'
    if (dart.library.html) 'pwa/pwa_update_listener_web.dart' as impl;

/// PWA(서비스 워커) 새 버전 감지를 담당하는 서비스(웹 전용).
///
/// 비웹 플랫폼(모바일/데스크톱)에서는 서비스 워커가 존재하지 않으므로
/// 스텁 구현이 아무 동작도 하지 않는다. 웹에서는 `flutter build web`이
/// 생성하는 `flutter_service_worker.js`를 그대로 유지한 채, 새 서비스
/// 워커가 페이지를 장악하는 순간(`controllerchange`)을 감지해 알려준다.
class PwaUpdateService {
  PwaUpdateService._();

  /// 새 버전의 서비스 워커가 활성화되면 [onUpdateAvailable]을 호출한다.
  static void listenForUpdate(void Function() onUpdateAvailable) {
    impl.listenForServiceWorkerUpdate(onUpdateAvailable);
  }

  /// 사용자가 "새로고침"을 선택했을 때 페이지를 다시 로드한다.
  static void reload() {
    impl.reloadPage();
  }
}
