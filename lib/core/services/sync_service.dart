import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reducer/features/gallery/data/models/history_item.dart';
import 'package:reducer/features/auth/presentation/controllers/auth_controller.dart';

/// Provider for the Sync Service
final syncServiceProvider = Provider<FirestoreSyncService>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  return FirestoreSyncService(user?.uid);
});

/// Service responsible for syncing edit history to the cloud.
class FirestoreSyncService {
  final String? userId;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirestoreSyncService(this.userId);

  bool get isAuthenticated => userId != null;

  /// Collection reference for the user's history.
  CollectionReference? get _historyCollection {
    if (userId == null) return null;
    return _db.collection('users').doc(userId).collection('history');
  }

  /// Sync a new history item to Firestore with retry logic.
  Future<void> syncItem(HistoryItem item, {int maxRetries = 3}) async {
    if (!isAuthenticated) return;

    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        await _historyCollection!.doc(item.id).set(item.toJson());
        debugPrint('[SyncService] Item ${item.id} synced to cloud.');
        return;
      } catch (e) {
        attempts++;
        debugPrint(
          '[SyncService] Sync attempt $attempts failed for item ${item.id}: $e',
        );
        if (attempts >= maxRetries) {
          debugPrint('[SyncService] Max retries reached for item ${item.id}.');
        } else {
          await Future.delayed(
            Duration(seconds: attempts * 2),
          ); // Exponential backoff
        }
      }
    }
  }

  /// Delete a history item from Firestore.
  Future<void> deleteItem(String id) async {
    if (!isAuthenticated) return;

    try {
      await _historyCollection!.doc(id).delete();
      debugPrint('[SyncService] Item $id deleted from cloud.');
    } catch (e) {
      debugPrint('[SyncService] Failed to delete item $id: $e');
    }
  }

  /// Get real-time stream of history items with pagination support.
  Stream<List<HistoryItem>> getCloudHistoryStream({int limit = 20}) {
    if (!isAuthenticated) return Stream.value([]);

    return _historyCollection!
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots(includeMetadataChanges: true)
        .distinct()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return HistoryItem.fromJson(doc.data() as Map<String, dynamic>);
          }).toList();
        });
  }

  /// Mass upload local items (useful after signing in).
  Future<void> syncLocalItems(List<HistoryItem> items) async {
    if (!isAuthenticated || items.isEmpty) return;

    // Firestore batch limit is 500 operations.
    final chunks = <List<HistoryItem>>[];
    for (var i = 0; i < items.length; i += 500) {
      chunks.add(
        items.sublist(i, i + 500 > items.length ? items.length : i + 500),
      );
    }

    for (final chunk in chunks) {
      final batch = _db.batch();
      for (final item in chunk) {
        batch.set(_historyCollection!.doc(item.id), item.toJson());
      }

      try {
        await batch.commit();
        debugPrint(
          '[SyncService] Batch sync of ${chunk.length} items complete.',
        );
      } catch (e) {
        debugPrint('[SyncService] Batch sync failed: $e');
      }
    }
  }
}
