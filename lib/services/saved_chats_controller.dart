import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/saved_chat.dart';

/// Saved chats: kept in memory and synced (best effort) to
/// Realtime Database at users/<uid>/savedChats.
class SavedChatsController extends ChangeNotifier {
  final List<SavedChat> _items = [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _loadError;

  List<SavedChat> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get loadError => _loadError;
  bool isSaved(String id) => _items.any((e) => e.id == id);

  DatabaseReference? _ref() {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return null;
      return FirebaseDatabase.instance.ref('users/$uid/savedChats');
    } catch (_) {
      return null;
    }
  }

  Future<void> load() async {
    if (_isLoading) return;
    _isLoading = true;
    _loadError = null;
    notifyListeners();
    final ref = _ref();
    if (ref == null) {
      _isLoading = false;
      _hasLoaded = true;
      notifyListeners();
      return;
    }
    try {
      final snap = await ref.get().timeout(const Duration(seconds: 8));
      final value = snap.value;
      if (value is Map) {
        value.forEach((key, v) {
          if (v is Map && !isSaved(key.toString())) {
            final chat = SavedChat.tryParse(key.toString(), v);
            if (chat != null) _items.add(chat);
          }
        });
        _items.sort((a, b) => b.savedAt.compareTo(a.savedAt));
        notifyListeners();
      }
    } catch (e) {
      _loadError = 'Saved chats could not be loaded. Check your connection and try again.';
      debugPrint('Loading saved chats failed: $e');
    } finally {
      _isLoading = false;
      _hasLoaded = true;
      notifyListeners();
    }
  }

  void save(SavedChat chat) {
    _items.removeWhere((e) => e.id == chat.id);
    _items.insert(0, chat);
    notifyListeners();
    _push(() => _ref()?.child(chat.id).set(chat.toMap()));
  }

  void remove(String id) {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
    _push(() => _ref()?.child(id).remove());
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  Future<void> _push(Future<void>? Function() action) async {
    try {
      await action()?.timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Syncing saved chats failed: $e');
    }
  }
}
