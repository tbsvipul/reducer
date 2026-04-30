import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reducer/features/auth/domain/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _usersCollection => _firestore.collection('users');

  /// Streams the user document from Firestore.
  Stream<UserModel?> streamUser(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  /// Creates or updates a user document in Firestore from Firebase Auth data.
  Future<void> createOrUpdateUserFromAuth({
    required User user,
    required String email,
    required String name,
    String? profileImageUrl,
  }) async {
    final docRef = _usersCollection.doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      final newUser = UserModel(
        uid: user.uid,
        email: email,
        name: name,
        profileImageUrl: profileImageUrl,
      );
      await docRef.set(newUser.toFirestore());
    } else {
      // Update basic info if needed, but don't overwrite subscription data
      final updateData = {
        'email': email,
        'name': name,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (profileImageUrl != null) {
        updateData['profileImageUrl'] = profileImageUrl;
      }
      await docRef.update(updateData);
    }
  }

  /// Updates specific fields for a user document.
  Future<void> updateFields(String uid, Map<String, dynamic> data) async {
    await _usersCollection.doc(uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Alias for updateFields, used in purchase_datasource.dart
  Future<void> updateSubscription(String uid, Map<String, dynamic> data) async {
    await updateFields(uid, data);
  }

  /// Requests account deletion by creating a document in the deletion_requests collection.
  Future<void> requestAccountDeletion({
    required String uid,
    required String email,
  }) async {
    await _firestore.collection('deletion_requests').doc(uid).set({
      'uid': uid,
      'email': email,
      'requestedAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  /// Fetches a user document once.
  Future<UserModel?> getUser(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }
}
