import 'dart:io';
import 'package:reducer/features/auth/domain/models/user_model.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  AppUser? get currentUser;

  Future<AppUser> signInWithEmail(String email, String password);

  Future<AppUser> signUpWithEmail(
    String email,
    String password,
    String displayName,
  );

  Future<AppUser> signInWithGoogle();

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> changePassword(String currentPassword, String newPassword);

  /// Updates the user's display name in Auth and Firestore.
  Future<void> updateDisplayName(String displayName);

  /// Updates the user's profile photo URL in Auth and Firestore.
  Future<void> updateProfilePhoto(String photoUrl);

  /// Uploads a new profile image file and updates the user's profile.
  Future<void> updateProfileImage(File file);

  /// Deletes the user's account and associated data from Firestore.
  Future<void> deleteAccount();

  /// Re-authenticates the current user with their [password].
  Future<void> reauthenticate(String password);

  /// Sends an email verification link to the current user's email.
  Future<void> sendEmailVerification();

  /// Signs in the user anonymously.
  Future<void> signInAnonymously();
}
