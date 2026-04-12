import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:reducer/features/gallery/data/models/history_item.dart';
import 'package:reducer/core/services/sync_service.dart';

class HistoryState {
  final List<HistoryItem> items;
  final bool isLoading;

  const HistoryState({
    this.items = const [],
    this.isLoading = false,
  });

  HistoryState copyWith({
    List<HistoryItem>? items,
    bool? isLoading,
  }) {
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
  static const _storageKey = 'edit_history_v2';

  @override
  Future<HistoryState> build() async {
    // Fix: Async build initializes state before any method reads it.
    final items = await _loadItemsFromStorage();
    return HistoryState(items: items, isLoading: false);
  }

  Future<void> loadHistory() async {
    final current = await _readSafeState();
    state = AsyncValue.data(current.copyWith(isLoading: true));

    final nextState = await AsyncValue.guard(() async {
      final items = await _loadItemsFromStorage();
      return HistoryState(items: items, isLoading: false);
    });

    state = nextState;
  }


  Future<void> addItem(HistoryItem item) async {
    final current = await _readSafeState();
    final updatedItems = [item, ...current.items]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    state = AsyncValue.data(
      current.copyWith(items: updatedItems, isLoading: false),
    );

    // ── CLOUD SYNC: Real-time backup ──────────────────────────────────
    final syncService = ref.read(syncServiceProvider);
    unawaited(syncService.syncItem(item));

    // Fix: Persist in background to keep save flow responsive.
    unawaited(_saveToStorage(updatedItems));
  }

  Future<void> removeItem(String id) async {
    final current = await _readSafeState();
    final updatedItems = current.items
        .where((item) => item.id != id)
        .toList(growable: false);

    state = AsyncValue.data(
      current.copyWith(items: updatedItems, isLoading: false),
    );

    // ── CLOUD SYNC: Real-time deletion ────────────────────────────────
    final syncService = ref.read(syncServiceProvider);
    unawaited(syncService.deleteItem(id));

    unawaited(_saveToStorage(updatedItems));
  }

  Future<void> clearAll() async {
    final current = await _readSafeState();
    state = AsyncValue.data(
      current.copyWith(items: const [], isLoading: false),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<HistoryState> _readSafeState() async {
    final value = state.valueOrNull;
    if (value != null) return value;
    // Fix: Wait for provider initialization when called from write flows.
    return future;
  }

  Future<List<HistoryItem>> _loadItemsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_storageKey);
      if (historyJson == null || historyJson.isEmpty) {
        return const [];
      }

      // Fix: Decode work stays off the UI isolate.
      return compute(_decodeHistory, historyJson);
    } catch (e) {
      debugPrint('Failed to load history: $e');
      return const [];
    }
  }

  Future<void> _saveToStorage(List<HistoryItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Fix: JSON encoding is moved off the UI isolate.
      final historyJson = await compute(_encodeHistory, items);
      await prefs.setStringList(_storageKey, historyJson);
    } catch (e) {
      debugPrint('Failed to save history: $e');
    }
  }
}

extension SafeHistoryRead on WidgetRef {
  Future<HistoryController> readHistoryControllerReady() async {
    // Fix: .future guarantees notifier state is initialized before use.
    await read(historyControllerProvider.future);
    return read(historyControllerProvider.notifier);
  }
}

List<String> _encodeHistory(List<HistoryItem> items) {
  return items.map((item) => jsonEncode(item.toJson())).toList(growable: false);
}

List<HistoryItem> _decodeHistory(List<String> historyJson) {
  final items = <HistoryItem>[];

  for (final rawItem in historyJson) {
    try {
      final decoded = jsonDecode(rawItem) as Map<String, dynamic>;
      items.add(HistoryItem.fromJson(decoded));
    } catch (e) {
      debugPrint('Skipping corrupt history entry: $e');
    }
  }

  items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return items;
}
