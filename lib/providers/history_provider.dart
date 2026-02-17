import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_item.dart';

/// Provider for managing edit history with persistence
final historyProvider = ChangeNotifierProvider<HistoryNotifier>((ref) {
  return HistoryNotifier();
});

class HistoryNotifier extends ChangeNotifier {
  List<HistoryItem> _items = [];
  static const String _storageKey = 'edit_history';
  static const int _maxItems = 20;

  List<HistoryItem> get items => List.unmodifiable(_items);

  /// Load history from  SharedPreferences
  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _items = jsonList
            .map((json) => HistoryItem.fromJson(json as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading history: $e');
      _items = [];
    }
  }

  /// Add new item to history (most recent first)
  Future<void> addItem(HistoryItem item) async {
    _items.insert(0, item); // Most recent first
    
    // Keep only last 20 items
    if (_items.length > _maxItems) {
      _items = _items.sublist(0, _maxItems);
    }
    
    await _saveToPrefs();
    notifyListeners();
  }

  /// Remove item from history
  Future<void> removeItem(String id) async {
    try {
      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        final item = _items[index];
        
        // Clean up thumbnail
        final thumbFile = File(item.thumbnailPath);
        if (await thumbFile.exists()) await thumbFile.delete();
        
        // Clean up bulk directory if it exists
        if (item.isBulk) {
          final bulkDir = Directory(thumbFile.parent.path + '/bulk_${item.id}');
          if (await bulkDir.exists()) {
            await bulkDir.delete(recursive: true);
          }
        }
        
        _items.removeAt(index);
        await _saveToPrefs();
        notifyListeners();
      }
    } catch (e) {
      print('Error removing item/cleaning files: $e');
    }
  }

  /// Clear all history
  Future<void> clearAll() async {
    try {
      for (final item in _items) {
        final thumbFile = File(item.thumbnailPath);
        if (await thumbFile.exists()) await thumbFile.delete();
        
        if (item.isBulk) {
          final bulkDir = Directory(thumbFile.parent.path + '/bulk_${item.id}');
          if (await bulkDir.exists()) {
            await bulkDir.delete(recursive: true);
          }
        }
      }
      _items.clear();
      await _saveToPrefs();
      notifyListeners();
    } catch (e) {
      print('Error clearing history: $e');
      _items.clear();
      notifyListeners();
    }
  }

  /// Save to SharedPreferences
  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _items.map((item) => item.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      print('Error saving history: $e');
    }
  }
}
