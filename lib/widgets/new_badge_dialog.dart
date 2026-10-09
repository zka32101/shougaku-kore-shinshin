import 'package:flutter/material.dart';

/// バッジ獲得の達成演出ダイアログ（算数の NewBadgeDialog と同じ見た目）。
class NewBadgeDialog extends StatelessWidget {
  final List<String> badgeNames;
  final VoidCallback? onClose;

  const NewBadgeDialog({super.key, required this.badgeNames, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 250,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset('assets/celebrate/celebrate_starburst.webp',
                        width: 250, fit: BoxFit.contain),
                    Image.asset('assets/celebrate/celebrate_medal.webp',
                        width: 130, fit: BoxFit.contain),
                  ],
                ),
              ),
              SizedBox(
                width: 260,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset('assets/celebrate/celebrate_ribbon_banner.webp',
                        width: 260, fit: BoxFit.contain),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 44),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'おめでとう！',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF461905),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              for (final n in badgeNames)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    n,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onClose?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('了解'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
