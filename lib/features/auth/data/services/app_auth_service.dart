import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as google_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final google_auth.GoogleSignIn _googleSignIn = google_auth.GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Trigger the Google Authentication flow
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // 2. Obtain the auth details from the request
      final googleAuth = await googleUser.authentication;

      // 3. Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Once signed in, return the UserCredential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('AuthService: Google Sign-In error: $e');
      rethrow;
    }
  }

  // Register with Email
  Future<UserCredential> registerWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Login with Email
  Future<UserCredential> loginWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      debugPrint('AuthService: Sign-out error: $e');
    }
  }

  // Sign in anonymously
  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      debugPrint('AuthService: Anonymous sign-in failed: $e');
      return null;
    }
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('AuthService: Password reset error: $e');
      rethrow;
    }
  }

  // Delete Account (Mandatory for App Store compliance)
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      
      // Attempt deletion
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        debugPrint('AuthService: Token stale. Re-authentication required.');
      }
      rethrow;
    } catch (e) {
      debugPrint('AuthService: Unexpected account deletion error: $e');
      rethrow;
    }
  }
}

