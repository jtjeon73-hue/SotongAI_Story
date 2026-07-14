import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../core/storage/favorites_storage.dart';
import '../theme/app_colors.dart';

/// 즐겨찾기 토글 버튼. [FavoritesStorage] 상태를 직접 구독해 즉시 반영한다.
class FavoriteButton extends StatefulWidget {
  const FavoriteButton({
    super.key,
    required this.category,
    required this.id,
    this.size = 22,
  });

  final FavoriteCategory category;
  final String id;
  final double size;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  FavoritesStorage? _storage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final storage = AppScope.of(context).favorites;
    if (_storage != storage) {
      _storage?.removeListener(_onChanged);
      _storage = storage;
      _storage!.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    _storage?.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final storage = _storage;
    final isFavorite = storage?.isFavorite(widget.category, widget.id) ?? false;
    return Semantics(
      button: true,
      label: isFavorite ? '즐겨찾기 해제' : '즐겨찾기 추가',
      child: Tooltip(
        message: isFavorite ? '즐겨찾기 해제' : '즐겨찾기 추가',
        child: SizedBox(
          width: 44,
          height: 44,
          child: IconButton(
            onPressed: storage == null
                ? null
                : () => storage.toggle(widget.category, widget.id),
            icon: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              size: widget.size,
              color: isFavorite ? AppColors.error : AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}
