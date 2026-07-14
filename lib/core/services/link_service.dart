import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_constants.dart';

/// 외부 URL 열기 및 메일 작성 링크 실행을 담당하는 서비스.
class LinkService {
  LinkService._();

  /// [urlString]을 외부 브라우저/앱으로 연다. 실패 시 스낵바로 안내한다.
  static Future<void> openUrl(BuildContext context, String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri == null) {
      _showError(context, '유효하지 않은 링크입니다.');
      return;
    }
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        if (context.mounted) _showError(context, '링크를 열 수 없습니다: $urlString');
      }
    } catch (_) {
      if (context.mounted) _showError(context, '링크를 여는 중 문제가 발생했습니다.');
    }
  }

  /// 오류 제보용 메일 작성 화면을 연다.
  static Future<void> openErrorReportEmail(
    BuildContext context, {
    String? pageContext,
  }) async {
    final body = pageContext == null
        ? ''
        : Uri.encodeComponent('제보 위치: $pageContext\n\n오류 내용:\n');
    final uri = Uri.parse(
      'mailto:${AppConstants.contactEmail}'
      '?subject=${Uri.encodeComponent(AppConstants.errorReportSubject)}'
      '${body.isEmpty ? '' : '&body=$body'}',
    );
    try {
      final launched = await launchUrl(uri);
      if (!launched && context.mounted) {
        _showError(
          context,
          '메일 앱을 열 수 없습니다. ${AppConstants.contactEmail}로 직접 보내주세요.',
        );
      }
    } catch (_) {
      if (context.mounted) {
        _showError(
          context,
          '메일 앱을 열 수 없습니다. ${AppConstants.contactEmail}로 직접 보내주세요.',
        );
      }
    }
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
