import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:reducer/features/gallery/data/models/history_item.dart';
import 'package:reducer/core/services/sync_service.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';

class HistoryState {
  final List<HistoryItem> items;
  final bool isLoading;

  const HistoryState({this.items = const [], this.isLoading = false});

  HistoryState copyWith({List<HistoryItem>? items, bool? isLoading}) {
    return HistoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final historyControllerProvider =
    AutoDisposeAsyncNotifierProvider<HistoryController, HistoryState>(
      HistoryController.new,
    );

class HistoryController extends AutoDisposeAsyncNotifier<HistoryState> {
  static const _secureStorageKey = 'edit_history_secure_v1';
  static const _sharedPrefsKey = 'edit_history_v3';
  static const _legacyKey = 'edit_history_v2';
  static const _secureStorage = FlutterSecureStorage();

  /// Initialized the history state and sets up listeners.
  @override
  Future<HistoryState> build() async {
    // Watch auth state changes. When user logs in/out, this provider will rebuild.
    final userAsync = ref.watch(authStateChangesProvider);
    final user = userAsync.valueOrNull;
    final uid = user?.uid ?? 'guest';

    // Load items for this specific user
    final items = await _loadItemsFromStorage(uid);

    // If user just logged in (not guest), trigger cloud sync
    if (user != null && !user.isAnonymous) {
      _syncToCloud(items);
    }

    return HistoryState(items: items, isLoading: false);
  }

  void _syncToCloud(List<HistoryItem> items) {
    final syncService = ref.read(syncServiceProvider);
    unawaited(syncService.syncLocalItems(items));
  }

  /// Explicitly reloads the edit history from local storage.
  Future<void> loadHistory() async {
    await future;
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final user = ref.read(authStateChangesProvider).value;
      final uid = user?.uid ?? 'guest';
      final items = await _loadItemsFromStorage(uid);
      return HistoryState(items: items, isLoading: false);
    });
  }

  /// Adds a new [HistoryItem] to the local and cloud history.
  ///
  /// Automatically triggers a sync with Firestore if authenticated.
  Future<void> addItem(HistoryItem item) async {
    final current = await future;

    final updatedItems = [item, ...current.items]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    state = AsyncValue.data(
      current.copyWith(items: updatedItems, isLoading: false),
    );

    final syncService = ref.read(syncServiceProvider);
    unawaited(syncService.syncItem(item));

    final user = ref.read(authStateChangesProvider).value;
    final uid = user?.uid ?? 'guest';
    unawaited(_saveToStorage(updatedItems, uid));
  }

  /// Removes a history entry by its unique [id].
  Future<void> removeItem(String id) async {
    final current = await future;

    final updatedItems = current.items
        .where((item) => item.id != id)
        .toList(growable: false);

    state = AsyncValue.data(
      current.copyWith(items: updatedItems, isLoading: false),
    );

    final syncService = ref.read(syncServiceProvider);
    unawaited(syncService.deleteItem(id));

    final user = ref.read(authStateChangesProvider).value;
    final uid = user?.uid ?? 'guest';
    unawaited(_saveToStorage(updatedItems, uid));
  }

  /// Clears all history entries for the current user session.
  Future<void> clearAll() async {
    await future;

    state = const AsyncValue.data(HistoryState(items: [], isLoading: false));

    final user = ref.read(authStateChangesProvider).value;
    final uid = user?.uid ?? 'guest';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_sharedPrefsKey}_$uid');
  }

  Future<List<HistoryItem>> _loadItemsFromStorage(String uid) async {
    try {
      final userKey = '${_sharedPrefsKey}_$uid';
      final prefs = await SharedPreferences.getInstance();

      // 1. Initial migration from global to user-specific if needed
      if (!prefs.containsKey(userKey) && uid != 'guest') {
        await _migrateToUserSpecific(uid);
      }

      // 2. Migration from insecure/secure storage if necessary
      await _migrateToSharedPreferences();

      // 3. Read from shared preferences using user-specific key
      final historyJsonRaw = prefs.getString(userKey);

      if (historyJsonRaw == null || historyJsonRaw.isEmpty) {
        return const [];
      }

      // PERF: Offload entire JSON string decoding and object mapping to isolate
      return compute(_decodeHistoryFromRaw, historyJsonRaw);
    } catch (e) {
      debugPrint('[Storage] Failed to load history: $e');
      return const [];
    }
  }

  Future<void> _saveToStorage(List<HistoryItem> items, String uid) async {
    try {
      // PERF: Offload entire object graph serialization and JSON encoding to isolate
      final historyJsonRaw = await compute(_encodeHistoryToRaw, items);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('${_sharedPrefsKey}_$uid', historyJsonRaw);
    } catch (e) {
      debugPrint('[Storage] Failed to save history: $e');
    }
  }

  Future<void> _migrateToUserSpecific(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_sharedPrefsKey)) {
      final globalData = prefs.getString(_sharedPrefsKey);
      if (globalData != null) {
        await prefs.setString('${_sharedPrefsKey}_$uid', globalData);
        // We keep the global data for now to allow migration for other users
        // if they were sharing the same session, though unlikely.
        // Or just remove it if we assume it's the primary user.
        await prefs.remove(_sharedPrefsKey);
      }
    }
  }

  Future<void> _migrateToSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // If we already have the new key, no migration needed
      if (prefs.containsKey(_sharedPrefsKey)) return;

      String? historyToMigrate;

      // 1. Try to get from Secure Storage (v1)
      try {
        historyToMigrate = await _secureStorage.read(key: _secureStorageKey);
      } catch (e) {
        debugPrint('[Storage] Could not read from secure storage: $e');
      }

      // 2. If secure storage is empty, check old legacy key (v2)
      if (historyToMigrate == null || historyToMigrate.isEmpty) {
        if (prefs.containsKey(_legacyKey)) {
          final legacyList = prefs.getStringList(_legacyKey);
          if (legacyList != null && legacyList.isNotEmpty) {
            historyToMigrate = jsonEncode(legacyList);
          }
        }
      }

      // 3. If we found data, save it to the new key
      if (historyToMigrate != null && historyToMigrate.isNotEmpty) {
        debugPrint('[Storage] Migrating history to SharedPreferences...');
        await prefs.setString(_sharedPrefsKey, historyToMigrate);
      }

      // 4. Cleanup old storage
      await _secureStorage.delete(key: _secureStorageKey);
      await prefs.remove(_legacyKey);

      debugPrint('[Storage] History migration complete.');
    } catch (e) {
      debugPrint('[Storage] Migration failed: $e');
    }
  }
}

String _encodeHistoryToRaw(List<HistoryItem> items) {
  final list = items
      .map((item) => jsonEncode(item.toJson()))
      .toList(growable: false);
  return jsonEncode(list);
}

List<HistoryItem> _decodeHistoryFromRaw(String rawJson) {
  final items = <HistoryItem>[];
  try {
    final historyJson = (jsonDecode(rawJson) as List).cast<String>();

    for (final rawItem in historyJson) {
      try {
        final decoded = jsonDecode(rawItem) as Map<String, dynamic>;
        items.add(HistoryItem.fromJson(decoded));
      } catch (e) {
        debugPrint('Skipping corrupt history entry: $e');
      }
    }

    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  } catch (e) {
    debugPrint('History decoding failed: $e');
  }
  return items;
}
