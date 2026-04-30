import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  })  : _auth = auth ?? FirebaseAuth.instance,
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
      if (credential.user == null) throw AuthException('User not found after sign in.');
      
      final appUser = AppUser.fromFirebase(credential.user!);
      
      // Check if account is disabled in Firestore
      final userDoc = await _firestore.collection('users').doc(appUser.uid).get();
      if (userDoc.exists && (userDoc.data()?['isAccountDisabled'] ?? false)) {
        await signOut();
        throw AuthException('This account has been disabled. Please contact support for assistance.');
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
  Future<AppUser> signUpWithEmail(String email, String password, String displayName) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) throw AuthException('User not created.');

      await credential.user!.updateDisplayName(displayName);
      await credential.user!.reload();
      
      final updatedUser = _auth.currentUser!;
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

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user == null) {
        throw AuthException('Failed to sign in with Google.');
      }

      final appUser = AppUser.fromFirebase(userCredential.user!);
      
      // Check if account is disabled in Firestore
      final userDoc = await _firestore.collection('users').doc(appUser.uid).get();
      if (userDoc.exists && (userDoc.data()?['isAccountDisabled'] ?? false)) {
        await signOut();
        throw AuthException('This account has been disabled. Please contact support for assistance.');
      }

      await _updateUserInFirestore(appUser);
      return appUser;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    } on PlatformException catch (e) {
      if (e.code == '12501' || e.code == 'sign_in_canceled') {
        throw AuthException('Google Sign-In was cancelled.', 'cancelled');
      }
      if (e.code == 'network_error') {
        throw AuthException('Network error occurred. Please check your connection.', 'network_error');
      }
      throw AuthException('Google Sign-In error: ${e.message ?? e.toString()}', e.code);
    } catch (e) {
      if (e.toString().contains('12501')) {
        throw AuthException('Google Sign-In was cancelled.', 'cancelled');
      }
      throw AuthException(e.toString());
    }
  }


  @override
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
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
  Future<void> changePassword(String currentPassword, String newPassword) async {
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
      await _updateUserInFirestore(AppUser.fromFirebase(user));
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    }
  }

  @override
  Future<void> updateProfileImage(File file) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw AuthException('No user logged in.');

      final downloadUrl = await _cloudinaryService.uploadProfileImage(file, user.uid);
      
      if (downloadUrl == null) throw AuthException('Failed to upload image to Cloudinary.');

      await user.updatePhotoURL(downloadUrl);
      
      // Use the direct URL to ensure Firestore is updated with the latest image immediately
      final appUser = AppUser.fromFirebase(user).copyWith(photoUrl: downloadUrl);
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
      
      // 1. Mark account as disabled in Firestore instead of deleting
      await _firestore.collection('users').doc(user.uid).update({
        'isAccountDisabled': true,
        'disabledAt': FieldValue.serverTimestamp(),
      });
      
      // 2. Perform auto logout
      await signOut();
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

      final AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
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
      final credential = await _auth.signInAnonymously();
      if (credential.user != null) {
        await _updateUserInFirestore(AppUser.fromFirebase(credential.user!));
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    }
  }

  Future<void> _updateUserInFirestore(AppUser user) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    await docRef.set(user.toJson(), SetOptions(merge: true));
  }
}
