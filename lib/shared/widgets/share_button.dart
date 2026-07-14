import 'package:flutter/material.dart';

import '../../core/services/share_service.dart';
import '../theme/app_colors.dart';

/// 공유 옵션(링크 복사/제목+링크 복사/공유하기)을 제공하는 버튼.
class ShareButton extends StatelessWidget {
  const ShareButton({
    super.key,
    required this.title,
    required this.url,
    this.text,
  });

  final String title;
  final String url;
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '공유하기',
      child: Tooltip(
        message: '공유하기',
        child: PopupMenuButton<_ShareAction>(
          tooltip: '',
          icon: const Icon(Icons.share_rounded, color: AppColors.muted),
          onSelected: (action) async {
            switch (action) {
              case _ShareAction.copyLink:
                await ShareService.copyLink(context, url);
                break;
              case _ShareAction.copyTitleLink:
                await ShareService.copyTitleAndLink(
                  context,
                  title: title,
                  url: url,
                );
                break;
              case _ShareAction.share:
                await ShareService.share(
                  context,
                  title: title,
                  url: url,
                  text: text,
                );
                break;
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: _ShareAction.copyLink, child: Text('링크 복사')),
            PopupMenuItem(
              value: _ShareAction.copyTitleLink,
              child: Text('제목+링크 복사'),
            ),
            PopupMenuItem(value: _ShareAction.share, child: Text('공유하기')),
          ],
        ),
      ),
    );
  }
}

enum _ShareAction { copyLink, copyTitleLink, share }
