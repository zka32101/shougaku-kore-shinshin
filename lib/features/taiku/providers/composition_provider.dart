import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/composition.dart';
import 'child_profiles_provider.dart';

final compositionProvider =
    StateNotifierProvider<CompositionNotifier, AsyncValue<CompositionCollection>>((ref) {
  return CompositionNotifier(ref);
});

class CompositionNotifier extends StateNotifier<AsyncValue<CompositionCollection>> {
  CompositionNotifier(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  final Ref ref;
  static const String _cacheKey = 'composition_cache';

  String get _userId =>
      ref.read(currentChildProfileProvider)?.id ?? 'anonymous';

  Future<void> _init() async {
    try {
      final cached = await _getCache();
      if (cached != null) {
        state = AsyncValue.data(cached);
      }
      await fetch();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> fetch() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('compositions')
          .orderBy('createdAt', descending: true)
          .get();

      final compositions = snapshot.docs
          .map((doc) => Composition.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      final collection = CompositionCollection(compositions);
      state = AsyncValue.data(collection);
      await _saveCache(collection);
    } catch (e, st) {
      // オフライン時はキャッシュのみで継続（既にstateにcacheがあればそのまま）
      if (state.valueOrNull == null) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> add(Composition composition) async {
    final current = state.valueOrNull;
    final optimistic = CompositionCollection([composition, ...?current?.items]);
    state = AsyncValue.data(optimistic);
    await _saveCache(optimistic);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('compositions')
          .doc(composition.id)
          .set(composition.toJson());
    } catch (_) {
      // オフライン保存は成功済み。次回fetch時に再同期を試みる
    }
  }

  Future<void> delete(String id) async {
    final current = state.valueOrNull;
    if (current != null) {
      final updated =
          CompositionCollection(current.items.where((c) => c.id != id).toList());
      state = AsyncValue.data(updated);
      await _saveCache(updated);
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('compositions')
          .doc(id)
          .delete();
    } catch (_) {}
  }

  Future<void> _saveCache(CompositionCollection collection) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, collection.toJsonString());
    } catch (_) {}
  }

  Future<CompositionCollection?> _getCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_cacheKey);
      return json != null ? CompositionCollection.fromJsonString(json) : null;
    } catch (_) {
      return null;
    }
  }
}
