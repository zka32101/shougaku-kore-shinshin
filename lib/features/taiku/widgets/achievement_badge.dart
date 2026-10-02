import 'package:flutter/material.dart';

class AchievementBadge extends StatelessWidget {
  final String title;
  final String emoji;
  final bool unlocked;

  const AchievementBadge({
    super.key,
    required this.title,
    required this.emoji,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked ? Colors.amber[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: unlocked ? Colors.amber : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: unlocked ? Colors.amber[900] : Colors.grey,
            ),
          ),
          if (unlocked)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '達成！',
                style: TextStyle(fontSize: 9, color: Colors.amber[700]),
              ),
            ),
        ],
      ),
    );
  }
}
