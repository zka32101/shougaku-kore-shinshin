import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/animal_avatar.dart';
import '../features/shop/decor/decor_scope.dart';
import '../providers/local_avatar_provider.dart';

/// 動物アバターの丸いイラスト
class AnimalAvatarImage extends StatelessWidget {
  final AnimalAvatar avatar;
  final double size;
  final double opacity;

  const AnimalAvatarImage({
    super.key,
    required this.avatar,
    required this.size,
    this.opacity = 1,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Opacity(
        opacity: opacity,
        child: Image.asset(
          avatar.imageAsset,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            width: size,
            height: size,
            color: Colors.grey[200],
            child: Icon(Icons.pets, size: size * 0.5, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}

/// 選んでいるアバターの表示。ホーム画面やプロフィール画面で使う。
class AvatarDisplayWidget extends ConsumerWidget {
  final double size;
  final VoidCallback? onTap;
  final bool showName;

  const AvatarDisplayWidget({
    super.key,
    this.size = 80,
    this.onTap,
    this.showName = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatar = ref.watch(localAvatarProvider).selected;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: DecorFrame(
              size: size,
              child: AnimalAvatarImage(avatar: avatar, size: size),
            ),
          ),
          if (showName) ...[
            const SizedBox(height: 8),
            Text(avatar.name, style: const TextStyle(fontSize: 12)),
          ],
        ],
      ),
    );
  }
}

/// ホーム画面のヘッダー（アバター・あいさつ・コイン）
class AvatarPanel extends ConsumerWidget {
  final String? userName;

  const AvatarPanel({
    super.key,
    this.userName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(localAvatarProvider).coins;
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/avatar_selection'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.blue[100]!],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const AvatarDisplayWidget(size: 64, showName: false),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (userName != null) ...[
                    Text(
                      'こんにちは、$userName！',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    '🪙 $coins　アバターを選ぶ',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
