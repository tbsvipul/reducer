import 'package:firebase_auth/firebase_auth.dart';

class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, [this.code]);

  factory AuthException.fromFirebase(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return AuthException('The email address is badly formatted.', e.code);
      case 'user-disabled':
        return AuthException('This user has been disabled. Please contact support.', e.code);
      case 'user-not-found':
        return AuthException('No user found with this email.', e.code);
      case 'wrong-password':
        return AuthException('Incorrect password. Please try again.', e.code);
      case 'email-already-in-use':
        return AuthException('An account already exists for this email.', e.code);
      case 'operation-not-allowed':
        return AuthException('Operation not allowed. Please contact support.', e.code);
      case 'weak-password':
        return AuthException('The password provided is too weak.', e.code);
      case 'network-request-failed':
        return AuthException('Network error. Please check your internet connection.', e.code);
      case 'invalid-credential':
        return AuthException('Invalid credentials provided.', e.code);
      case 'requires-recent-login':
        return AuthException('This operation is sensitive and requires recent authentication. Please log in again.', e.code);
      default:
        return AuthException(e.message ?? 'An unknown error occurred.', e.code);
    }
  }

  @override
  String toString() => message;
}
