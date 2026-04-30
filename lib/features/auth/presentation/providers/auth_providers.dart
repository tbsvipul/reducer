import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reducer/features/auth/data/services/app_auth_service.dart';
import 'package:reducer/features/auth/data/services/cloudinary_service.dart';
import 'package:reducer/features/auth/data/services/user_service.dart';
import 'package:reducer/features/auth/domain/models/user_model.dart';
import 'package:reducer/features/premium/data/datasources/purchase_datasource.dart';
import 'package:reducer/core/services/notification_service.dart';

// Service Providers
final authServiceProvider = Provider((ref) => AIImageProAuthService());
final userServiceProvider = Provider((ref) => UserService());

/// Required by the new auth architecture contract.
final cloudinaryProvider = Provider((ref) => CloudinaryService());

/// Backward-compatible alias for existing code.
final cloudinaryServiceProvider = cloudinaryProvider;

// Auth State Provider
final authProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Alias for backward compatibility
final authStateProvider = authProvider;

// User Data Provider (Firestore)
final userProvider = StreamProvider<UserModel?>((ref) {
  final authAsync = ref.watch(authProvider);
  return authAsync.when(
    data: (authState) {
      if (authState == null || authState.isAnonymous) return Stream.value(null);
      return ref.watch(userServiceProvider).streamUser(authState.uid);
    },
    loading: () => const Stream.empty(),
    error: (e, s) => Stream.error(e, s),
  );
});

// Auth Controller Provider
final authControllerProvider = StateNotifierProvider<AuthController, bool>((
  ref,
) {
  return AuthController(ref);
});

class AuthController extends StateNotifier<bool> {
  final Ref _ref;

  AuthController(this._ref) : super(false);

  /// Register with email/password and create/update user profile in Firestore.
  Future<void> register(String name, String email, String password) async {
    state = true;
    try {
      final credential = await _ref
          .read(authServiceProvider)
          .registerWithEmail(email.trim(), password.trim());
      final user = credential.user;
      if (user == null) {
        throw 'Registration failed. Please try again.';
      }

      await _ensureUserDocument(user, name: name.trim(), email: email.trim());
      await _ref
          .read(premiumControllerProvider.notifier)
          .fetchOffersAndCheckStatus();

      // Show welcome notification
      debugPrint(
        '[AuthController] Successful registration, triggering welcome notification',
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        NotificationService().showNotification(
          id: 1,
          title: 'Congratulations! 🎉',
          body: 'Registration successful! Start optimizing your gallery now.',
        );
      });
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    } finally {
      state = false;
    }
  }

  /// Login with email/password and ensure Firestore document exists.
  Future<void> login(String email, String password) async {
    state = true;
    try {
      final credential = await _ref
          .read(authServiceProvider)
          .loginWithEmail(email.trim(), password.trim());
      final user = credential.user;
      if (user == null) {
        throw 'Login failed. Please try again.';
      }

      await _ensureUserDocument(user, email: email.trim());
      await _ref
          .read(premiumControllerProvider.notifier)
          .fetchOffersAndCheckStatus();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'Login failed: $e';
    } finally {
      state = false;
    }
  }

  /// Sign in with Google and create/update Firestore user document.
  Future<bool> signInWithGoogle() async {
    state = true;
    try {
      final credential = await _ref
          .read(authServiceProvider)
          .signInWithGoogle();

      // If credential is null, user cancelled the flow
      if (credential == null) {
        return false;
      }

      final user = credential.user;
      if (user == null) {
        throw 'Google Sign-In failed. Please try again.';
      }

      await _ensureUserDocument(
        user,
        name: user.displayName,
        email: user.email,
        profileImageUrl: user.photoURL,
      );
      await _ref
          .read(premiumControllerProvider.notifier)
          .fetchOffersAndCheckStatus();

      // Show welcome notification if it's a new registration via Google
      if (credential.additionalUserInfo?.isNewUser == true) {
        debugPrint(
          '[AuthController] New Google user registered, triggering welcome notification',
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          NotificationService().showNotification(
            id: 1,
            title: 'Congratulations! 🎉',
            body:
                'Registration successful via Google! Start optimizing your gallery now.',
          );
        });
      }
      return true;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      debugPrint('[AuthController] Google Sign-In error: $e');
      throw 'Google Sign-In failed. Please try again.';
    } finally {
      state = false;
    }
  }

  Future<void> _ensureUserDocument(
    User user, {
    String? name,
    String? email,
    String? profileImageUrl,
  }) async {
    final resolvedEmail = (email ?? user.email ?? '').trim();
    final fallbackName = _fallbackNameFromEmail(resolvedEmail);

    await _ref
        .read(userServiceProvider)
        .createOrUpdateUserFromAuth(
          user: user,
          email: resolvedEmail,
          name: (name == null || name.trim().isEmpty)
              ? fallbackName
              : name.trim(),
          profileImageUrl: profileImageUrl,
        );
  }

  String _fallbackNameFromEmail(String email) {
    if (!email.contains('@')) return 'New User';
    final raw = email.split('@').first.trim();
    if (raw.isEmpty) return 'New User';
    return raw;
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Wrong email or password.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      default:
        return e.message ?? 'Authentication error occurred.';
    }
  }

  Future<void> logout() async {
    state = true;
    try {
      final authService = _ref.read(authServiceProvider);
      await authService.signOut();
      await _ref.read(premiumControllerProvider.notifier).clearProStatus();

      // Auto-re-sign-in anonymously to maintain a session for guest features
      await authService.signInAnonymously();
    } finally {
      state = false;
    }
  }

  /// Sends a password reset email to the given address.
  Future<void> sendPasswordResetEmail(String email) async {
    if (email.trim().isEmpty) throw 'Please enter your email address.';

    state = true;
    try {
      await _ref.read(authServiceProvider).sendPasswordResetEmail(email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'Failed to send reset email: $e';
    } finally {
      state = false;
    }
  }

  /// Picked image upload flow:
  /// 1) Upload image to Cloudinary (unsigned upload)
  /// 2) Persist secure URL in Firestore
  Future<void> updateProfileImage(File imageFile) async {
    final currentUser = _ref.read(authServiceProvider).currentUser;
    if (currentUser == null) return;

    state = true;
    try {
      final imageUrl = await _ref
          .read(cloudinaryProvider)
          .uploadImage(imageFile, userId: currentUser.uid);
      if (imageUrl == null || imageUrl.isEmpty) {
        throw 'Failed to upload image to Cloudinary.';
      }

      await _ref.read(userServiceProvider).updateFields(currentUser.uid, {
        'profileImageUrl': imageUrl,
      });
    } catch (e) {
      rethrow;
    } finally {
      state = false;
    }
  }

  Future<void> updateName(String name) async {
    final currentUser = _ref.read(authServiceProvider).currentUser;
    if (currentUser == null) return;

    state = true;
    try {
      await _ref.read(userServiceProvider).updateFields(currentUser.uid, {
        'name': name.trim(),
      });
    } finally {
      state = false;
    }
  }

  /// Delete account logic with compliance handling
  Future<void> deleteAccount() async {
    state = true;
    try {
      await _ref.read(authServiceProvider).deleteAccount();
      // On success, clear pro status locally
      await _ref.read(premiumControllerProvider.notifier).clearProStatus();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw 'For security, please logout and log back in before deleting your account.';
      }
      throw _handleAuthError(e);
    } catch (e) {
      throw 'Account deletion failed: $e';
    } finally {
      state = false;
    }
  }
}
