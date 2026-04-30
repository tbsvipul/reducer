import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reducer/features/auth/data/services/app_auth_service.dart';
import 'package:reducer/features/auth/data/services/user_service.dart';
import 'package:reducer/features/auth/domain/models/user_model.dart';

// Service Providers
final authServiceProvider = Provider((ref) => AppAuthService());
final userServiceProvider = Provider((ref) => UserService());

// Auth State Provider
final authProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Alias for backward compatibility
final authStateProvider = authProvider;

// User Data Provider (Firestore)
final userProvider = StreamProvider<AppUser?>((ref) {
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

