import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:reducer/core/exceptions/auth_exception.dart';
import 'package:reducer/features/auth/domain/models/user_model.dart';
import 'package:reducer/features/auth/domain/repositories/auth_repository.dart';
import 'package:reducer/core/services/cloudinary_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  final CloudinaryService _cloudinaryService;

  AuthRepositoryImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
    CloudinaryService? cloudinaryService,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn(),
       _cloudinaryService = cloudinaryService ?? CloudinaryService();

  @override
  Stream<AppUser?> get authStateChanges => _auth.authStateChanges().map((user) {
    if (user == null) return null;
    return AppUser.fromFirebase(user);
  });

  @override
  AppUser? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return AppUser.fromFirebase(user);
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null)
        throw AuthException('User not found after sign in.');

      final appUser = AppUser.fromFirebase(credential.user!);

      // Check if account is disabled in Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(appUser.uid)
          .get();
      if (userDoc.exists && (userDoc.data()?['isAccountDisabled'] ?? false)) {
        await signOut();
        throw AuthException(
          'This account has been disabled. Please contact support for assistance.',
        );
      }

      await _updateUserInFirestore(appUser);
      return appUser;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<AppUser> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) throw AuthException('User not created.');

      await credential.user!.updateDisplayName(displayName);
      await credential.user!.reload();

      // Send verification email per Firebase best practices
      await credential.user!.sendEmailVerification();

      final updatedUser = FirebaseAuth.instance.currentUser!;
      final appUser = AppUser.fromFirebase(updatedUser);
      await _updateUserInFirestore(appUser);
      return appUser;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException('Google Sign-In was cancelled.', 'cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      if (userCredential.user == null) {
        throw AuthException('Failed to sign in with Google.');
      }

      final appUser = AppUser.fromFirebase(userCredential.user!);

      // Check if account is disabled in Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(appUser.uid)
          .get();
      if (userDoc.exists && (userDoc.data()?['isAccountDisabled'] ?? false)) {
        await signOut();
        throw AuthException(
          'This account has been disabled. Please contact support for assistance.',
        );
      }

      await _updateUserInFirestore(appUser);
      return appUser;
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw AuthException.fromFirebase(e);
      }

      final errorStr = e.toString();
      if (errorStr.contains('12501') ||
          errorStr.contains('sign_in_canceled') ||
          errorStr.contains('canceled') ||
          errorStr.contains('GoogleSignInExceptionCode.canceled')) {
        throw AuthException('Google Sign-In was cancelled.', 'cancelled');
      }

      if (e is PlatformException) {
        if (e.code == 'network_error') {
          throw AuthException(
            'Network error occurred. Please check your connection.',
            'network_error',
          );
        }
        throw AuthException(
          'Google Sign-In error: ${e.message ?? e.toString()}',
          e.code,
        );
      }

      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
      }
    } catch (_) {
      // disconnect can fail if token already revoked
    }
    await _auth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    }
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw AuthException('No user logged in.');

      // Re-authenticate
      await reauthenticate(currentPassword);

      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    }
  }

  @override
  Future<void> updateDisplayName(String displayName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw AuthException('No user logged in.');

      await user.updateDisplayName(displayName);
      await user.reload();
      final refreshed = FirebaseAuth.instance.currentUser!;
      await _updateUserInFirestore(AppUser.fromFirebase(refreshed));
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    }
  }

  @override
  Future<void> updateProfileImage(File file) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw AuthException('No user logged in.');

      final downloadUrl = await _cloudinaryService.uploadProfileImage(
        file,
        user.uid,
      );

      if (downloadUrl == null)
        throw AuthException('Failed to upload image to Cloudinary.');

      await user.updatePhotoURL(downloadUrl);

      // Use the direct URL to ensure Firestore is updated with the latest image immediately
      final appUser = AppUser.fromFirebase(
        user,
      ).copyWith(photoUrl: downloadUrl);
      await _updateUserInFirestore(appUser);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> updateProfilePhoto(String photoUrl) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw AuthException('No user logged in.');

      await user.updatePhotoURL(photoUrl);
      await _updateUserInFirestore(AppUser.fromFirebase(user));
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw AuthException('No user logged in.');

      // 1. Mark account as disabled in Firestore first
      await _firestore.collection('users').doc(user.uid).update({
        'isAccountDisabled': true,
        'disabledAt': FieldValue.serverTimestamp(),
      });

      // 2. Actually delete the Auth user for compliance
      try {
        await user.delete();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          // Re-authentication is handled by the UI/Controller catching this specific error
          throw AuthException(
            'For security, please logout and log back in before deleting your account.',
            'requires-recent-login',
          );
        }
        rethrow;
      }

      // 3. Clear local session
      await signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> reauthenticate(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw AuthException('No user logged in.');

      final email = user.email;
      if (email == null) throw AuthException('User email not found.');

      final AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw AuthException('No user logged in.');
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    }
  }

  @override
  Future<void> signInAnonymously() async {
    try {
      // Add a timeout guard for anonymous sign-in to prevent startup hangs
      // Reduced timeout from 12s to 6s for better UX on slow networks.
      final credential = await _auth.signInAnonymously().timeout(
        const Duration(seconds: 6),
        onTimeout: () => throw TimeoutException('Anonymous sign-in timed out'),
      );
      if (credential.user != null) {
        await _updateUserInFirestore(AppUser.fromFirebase(credential.user!));
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    } on TimeoutException catch (e) {
      debugPrint('[Auth] $e');
    } catch (e) {
      debugPrint('[Auth] Anonymous sign-in failed: $e');
    }
  }

  Future<void> _updateUserInFirestore(AppUser user) async {
    final docRef = _firestore.collection('users').doc(user.uid);

    // Exclude ephemeral and server-managed fields from client-side Firestore writes
    final payload = user.toJson()
      ..remove('isEmailVerified')
      ..remove('isAnonymous')
      ..remove('isAccountDisabled')
      ..remove('subscriptionStatus')
      ..remove('billingPeriod')
      ..remove('expiryDate')
      ..remove('subscriptionStartDate');

    await docRef.set({
      ...payload,
      'lastLoginAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
