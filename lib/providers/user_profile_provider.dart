import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/literacy_core/literacy_core.dart'
    show GradeLevelExt;
import '../features/literacy_core/src/providers/grade_provider.dart'
    show gradeLevelProvider;
import '../features/taiku/providers/child_profiles_provider.dart';

/// 体育側が最初に自動で作るプロフィール名(未設定の目印)。
const kDefaultChildName = '子ども1';

/// 名前の最大文字数。
const kMaxProfileNameLength = 10;

/// 名前を整える(前後の空白を除く)。
String normalizeProfileName(String raw) => raw.trim();

/// 名前の検証。問題が無ければ null、あればやさしい日本語のメッセージを返す。
String? validateProfileName(String raw) {
  final name = normalizeProfileName(raw);
  if (name.isEmpty) return 'なまえを いれてね';
  if (name.runes.length > kMaxProfileNameLength) {
    return '$kMaxProfileNameLength もじまでだよ';
  }
  return null;
}

/// 名前が未設定(初期値/空)かどうか。
bool isDefaultProfileName(String? name) {
  final n = (name ?? '').trim();
  return n.isEmpty || n == kDefaultChildName;
}

const _kGradeNumberKey = 'profile_grade_number';
const _kCardDismissedKey = 'profile_name_card_dismissed';

/// 入力で決めた学年(1〜6)。未設定は null。ふりがなの学年判定に使う。
final profileGradeProvider =
    StateNotifierProvider<ProfileGradeNotifier, int?>((ref) {
  return ProfileGradeNotifier();
});

class ProfileGradeNotifier extends StateNotifier<int?> {
  ProfileGradeNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getInt(_kGradeNumberKey);
    if (v != null && v >= 1 && v <= 6 && mounted) state = v;
  }

  Future<void> set(int grade) async {
    if (grade < 1 || grade > 6) return;
    state = grade;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kGradeNumberKey, grade);
  }
}

/// 「名前を入れよう」カードを『あとで』で閉じたか。
final profileCardDismissedProvider =
    StateNotifierProvider<ProfileCardDismissedNotifier, bool>((ref) {
  return ProfileCardDismissedNotifier();
});

class ProfileCardDismissedNotifier extends StateNotifier<bool> {
  ProfileCardDismissedNotifier() : super(true) {
    // 読み込み前にカードがちらつかないよう、最初は「閉じた」扱いにしておく。
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) state = prefs.getBool(_kCardDismissedKey) ?? false;
  }

  Future<void> dismiss() async {
    state = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kCardDismissedKey, true);
  }
}

/// ホームなどに出す名前。未設定のときは null。
final displayNameProvider = Provider<String?>((ref) {
  final p = ref.watch(currentChildProfileProvider);
  if (p == null || isDefaultProfileName(p.name)) return null;
  return p.name.trim();
});

/// 「名前を入れよう」カードを出すか。
final showNameCardProvider = Provider<bool>((ref) {
  final p = ref.watch(currentChildProfileProvider);
  if (p == null) return false;
  if (ref.watch(profileCardDismissedProvider)) return false;
  return isDefaultProfileName(p.name);
});

/// プロフィールを保存する。ID は変えない(体育・芸術・どうとくの保存データを守る)。
/// [grade] が null のときは学年を変えない。
Future<void> saveUserProfile(
  WidgetRef ref, {
  required String name,
  int? grade,
  String? emoji,
}) async {
  final err = validateProfileName(name);
  if (err != null) throw ArgumentError(err);
  final current = ref.read(currentChildProfileProvider);
  if (current == null) return;
  final gradeLevelValue = grade == null
      ? current.gradeLevel
      : GradeLevelExt.fromGrade(grade);
  await ref.read(childProfilesProvider.notifier).updateProfile(
        current.copyWith(
          name: normalizeProfileName(name),
          gradeLevel: gradeLevelValue,
          emoji: (emoji == null || emoji.isEmpty) ? current.emoji : emoji,
        ),
      );
  if (grade != null) {
    await ref.read(profileGradeProvider.notifier).set(grade);
    await ref.read(gradeLevelProvider.notifier).setGradeFromNumber(grade);
  }
  await ref.read(profileCardDismissedProvider.notifier).dismiss();
}
