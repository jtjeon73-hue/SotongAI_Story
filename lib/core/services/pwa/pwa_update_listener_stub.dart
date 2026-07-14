/// 비웹 플랫폼에는 서비스 워커가 없으므로 아무 것도 하지 않는 스텁 구현.
void listenForServiceWorkerUpdate(void Function() onUpdateAvailable) {}

/// 비웹 플랫폼에서는 페이지 새로고침 개념이 없으므로 아무 것도 하지 않는다.
void reloadPage() {}
