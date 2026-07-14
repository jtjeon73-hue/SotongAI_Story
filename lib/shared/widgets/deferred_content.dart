import 'package:flutter/material.dart';

import 'error_state.dart';
import 'loading_view.dart';

/// [ContentRepository]의 `ensureXxx()`류 지연 로딩 메서드를 화면 콘텐츠
/// 영역에서 손쉽게 사용하기 위한 공용 래퍼.
///
/// 앱 전체를 로딩 화면으로 가리는 대신, 이 위젯이 감싸는 콘텐츠 영역에만
/// 로딩 인디케이터 또는 재시도 가능한 에러 상태를 표시한다. [load]는
/// idempotent한 `ensureXxx()` 메서드를 넘기면 되며, 실패 후 재시도 시 다시
/// 호출된다.
class DeferredContent<T> extends StatefulWidget {
  const DeferredContent({
    super.key,
    required this.load,
    required this.builder,
    this.loadingMessage = '콘텐츠를 불러오는 중입니다...',
    this.errorTitle = '콘텐츠를 불러오지 못했습니다',
  });

  /// 데이터를 로드(또는 이미 로드되어 있다면 즉시 완료)하는 함수.
  final Future<T> Function() load;

  /// 로드가 끝난 뒤 실제 콘텐츠를 그리는 빌더. [load]가 완료된 값을 함께
  /// 전달받는다(단순히 `ensureXxx()`처럼 `void`를 반환하는 경우에는 무시해도 된다).
  final Widget Function(BuildContext context, T data) builder;

  final String loadingMessage;
  final String errorTitle;

  @override
  State<DeferredContent<T>> createState() => _DeferredContentState<T>();
}

class _DeferredContentState<T> extends State<DeferredContent<T>> {
  late Future<T> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.load();
  }

  void _retry() {
    setState(() => _future = widget.load());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return SizedBox(
            height: 220,
            child: LoadingView(message: widget.loadingMessage),
          );
        }
        if (snapshot.hasError) {
          return ErrorStateView(
            title: widget.errorTitle,
            message: '데이터를 불러오는 중 문제가 발생했습니다: ${snapshot.error}',
            onRetry: _retry,
          );
        }
        return widget.builder(context, snapshot.data as T);
      },
    );
  }
}
