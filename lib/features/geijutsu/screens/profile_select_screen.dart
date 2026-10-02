import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../providers/app_providers.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';

class ProfileSelectScreen extends ConsumerStatefulWidget {
  final bool isSwitch;
  const ProfileSelectScreen({super.key, this.isSwitch = false});

  @override
  ConsumerState<ProfileSelectScreen> createState() => _ProfileSelectScreenState();
}

class _ProfileSelectScreenState extends ConsumerState<ProfileSelectScreen> {
  Future<void> _selectProfile(UserProfile profile) async {
    await ref.read(profileProvider.notifier).setActive(profile.id);
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    }
  }

  Future<void> _showAddDialog() async {
    String name = '';
    String avatar = UserProfile.kDefaultAvatars[0];
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('プロフィールを作ろう！', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('アバターを選ぼう', style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: UserProfile.kDefaultAvatars.map((e) => GestureDetector(
                    onTap: () => setDlgState(() => avatar = e),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: avatar == e ? kPrimaryColor.withOpacity(0.2) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                        border: avatar == e ? Border.all(color: kPrimaryColor, width: 2) : null,
                      ),
                      child: Text(e, style: const TextStyle(fontSize: 24)),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  autofocus: true,
                  maxLength: 10,
                  decoration: InputDecoration(
                    labelText: '名前',
                    hintText: '例: まこ、たろう',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kPrimaryColor),
                    ),
                  ),
                  onChanged: (v) => name = v,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('キャンセル')),
            ElevatedButton(
              onPressed: () async {
                if (name.trim().isEmpty) return;
                final profile = UserProfile(
                  id: const Uuid().v4(),
                  name: name.trim(),
                  avatarEmoji: avatar,
                  createdAt: DateTime.now(),
                  grade: 0,
                );
                await ref.read(profileProvider.notifier).addProfile(profile);
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) await _selectProfile(profile);
              },
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              child: const Text('作成', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(UserProfile profile) async {
    String name = profile.name;
    String avatar = profile.avatarEmoji;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('プロフィールを編集', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('アバター', style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: UserProfile.kDefaultAvatars.map((e) => GestureDetector(
                    onTap: () => setDlgState(() => avatar = e),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: avatar == e ? kPrimaryColor.withOpacity(0.2) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                        border: avatar == e ? Border.all(color: kPrimaryColor, width: 2) : null,
                      ),
                      child: Text(e, style: const TextStyle(fontSize: 24)),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: name,
                  maxLength: 10,
                  decoration: InputDecoration(
                    labelText: '名前',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (v) => name = v,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: ctx,
                  builder: (_) => AlertDialog(
                    title: const Text('削除しますか？'),
                    content: Text('${profile.name}のデータがすべて削除されます'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('キャンセル')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('削除', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref.read(profileProvider.notifier).deleteProfile(profile.id);
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('削除', style: TextStyle(color: Colors.red)),
            ),
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('キャンセル')),
            ElevatedButton(
              onPressed: () async {
                if (name.trim().isEmpty) return;
                await ref.read(profileProvider.notifier).updateProfile(
                  profile.copyWith(name: name.trim(), avatarEmoji: avatar),
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              child: const Text('保存', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final profiles = profileState.profiles;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF6B35), Color(0xFFE91E8C), Color(0xFF9B59B6)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isSwitch) ...[
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 8),
                ],
                const Text(
                  'だれがやる？',
                  style: TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold,
                    color: Colors.white, letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'プロフィールを選んでね',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: profiles.length + 1,
                    itemBuilder: (context, i) {
                      if (i == profiles.length) {
                        return GestureDetector(
                          onTap: _showAddDialog,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white54, width: 2),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle_outline, color: Colors.white, size: 48),
                                SizedBox(height: 8),
                                Text('追加', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        );
                      }
                      final profile = profiles[i];
                      final isActive = profile.id == profileState.activeId;
                      return GestureDetector(
                        onTap: () => _selectProfile(profile),
                        onLongPress: () => _showEditDialog(profile),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isActive ? Colors.white : Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(20),
                            border: isActive ? Border.all(color: Colors.white, width: 3) : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(profile.avatarEmoji, style: const TextStyle(fontSize: 52)),
                              const SizedBox(height: 8),
                              Text(
                                profile.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: kTextDark,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (isActive)
                                const Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text('プレイ中', style: TextStyle(fontSize: 11, color: kPrimaryColor, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
