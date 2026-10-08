import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/user_profile_provider.dart';
import '../features/taiku/providers/child_profiles_provider.dart';

const _kEmojis = ['🧒', '👦', '👧', '🐱', '🐶', '🐰', '🦊', '🐼'];

/// なまえ・がくねん・アバター絵文字を決めるダイアログ。保存できたら true。
Future<bool> showProfileEditDialog(BuildContext context) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (_) => const ProfileEditDialog(),
  );
  return r == true;
}

class ProfileEditDialog extends ConsumerStatefulWidget {
  const ProfileEditDialog({super.key});

  @override
  ConsumerState<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends ConsumerState<ProfileEditDialog> {
  late final TextEditingController _ctrl;
  int? _grade;
  String? _emoji;
  String? _error;

  @override
  void initState() {
    super.initState();
    final p = ref.read(currentChildProfileProvider);
    _ctrl = TextEditingController(
        text: p == null || isDefaultProfileName(p.name) ? '' : p.name);
    _grade = ref.read(profileGradeProvider);
    _emoji = p?.emoji;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final err = validateProfileName(_ctrl.text);
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    await saveUserProfile(ref,
        name: _ctrl.text, grade: _grade, emoji: _emoji);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('なまえを いれよう'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _ctrl,
              maxLength: kMaxProfileNameLength,
              autofocus: false,
              decoration: InputDecoration(
                labelText: 'なまえ',
                hintText: '10もじまで',
                errorText: _error,
              ),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 8),
            const Text('がくねん', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (var g = 1; g <= 6; g++)
                  ChoiceChip(
                    label: Text('$g ねん'),
                    selected: _grade == g,
                    onSelected: (_) => setState(() => _grade = g),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('アバター（えらばなくてもOK）',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final e in _kEmojis)
                  ChoiceChip(
                    label: Text(e, style: const TextStyle(fontSize: 20)),
                    selected: _emoji == e,
                    onSelected: (_) => setState(() => _emoji = e),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('やめる'),
        ),
        FilledButton(onPressed: _save, child: const Text('きめた！')),
      ],
    );
  }
}
