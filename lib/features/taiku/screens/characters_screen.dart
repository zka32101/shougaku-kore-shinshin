import 'package:flutter/material.dart';
import '../taiku_app.dart';
import '../models/taiku_character.dart';

class CharactersScreen extends StatelessWidget {
  const CharactersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = <String>[];
    for (final c in taikuCharacters) {
      if (!categories.contains(c.category)) categories.add(c.category);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: TaikuColors.primary,
        title: const Text(
          '🏃 キャラクターずかん',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final category in categories) ...[
            Text(
              category,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
              children: taikuCharacters
                  .where((c) => c.category == category)
                  .map((c) => _CharacterCard(character: c))
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final TaikuCharacter character;
  const _CharacterCard({required this.character});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Image.asset(character.assetPath, fit: BoxFit.contain),
          ),
          const SizedBox(height: 6),
          Text(
            character.nameJp,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
