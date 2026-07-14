import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'web_share_stub.dart'
    if (dart.library.js_interop) 'web_share_web.dart'
    as web_share;

/// 링크/제목 공유 기능을 제공하는 서비스.
///
/// 웹에서는 가능한 경우 Web Share API를 사용하고, 그렇지 않으면 클립보드에
/// 복사한 뒤 스낵바로 안내한다. 데스크톱/모바일 네이티브 빌드에서는 항상
/// 클립보드 복사 방식을 사용한다.
class ShareService {
  ShareService._();

  /// 링크만 클립보드에 복사한다.
  static Future<void> copyLink(BuildContext context, String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) return;
    _showSnackBar(context, '링크가 복사되었습니다.');
  }

  /// 제목과 링크를 함께 클립보드에 복사한다.
  static Future<void> copyTitleAndLink(
    BuildContext context, {
    required String title,
    required String url,
  }) async {
    await Clipboard.setData(ClipboardData(text: '$title\n$url'));
    if (!context.mounted) return;
    _showSnackBar(context, '제목과 링크가 복사되었습니다.');
  }

  /// 가능하면 Web Share API로 공유 시트를 열고, 실패하거나 지원하지 않으면
  /// 제목+링크를 클립보드에 복사하는 방식으로 대체(fallback)한다.
  static Future<void> share(
    BuildContext context, {
    required String title,
    required String url,
    String? text,
  }) async {
    if (kIsWeb) {
      final ok = await web_share.tryWebShare(
        title: title,
        url: url,
        text: text,
      );
      if (ok) return;
    }
    if (!context.mounted) return;
    await copyTitleAndLink(context, title: title, url: url);
  }

  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
