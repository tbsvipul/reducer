import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:reducer/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:reducer/features/auth/domain/models/user_model.dart';
import 'package:reducer/features/auth/domain/repositories/auth_repository.dart';
import 'package:reducer/features/auth/presentation/providers/auth_providers.dart';
import 'package:reducer/core/services/cloudinary_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(
    cloudinaryService: ref.watch(cloudinaryServiceProvider),
  );
}

@riverpod
Stream<AppUser?> authStateChanges(AuthStateChangesRef ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

@riverpod
Stream<AppUser?> user(UserRef ref) {
  final authState = ref.watch(authStateChangesProvider).value;
  if (authState == null) return Stream.value(null);
  
  return FirebaseFirestore.instance
      .collection('users')
      .doc(authState.uid)
      .snapshots()
      .map((snapshot) => snapshot.exists ? AppUser.fromFirestore(snapshot) : authState);
}

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).signInWithEmail(email, password);
      state = const AsyncData(null);
    } catch (e, st) {
      debugPrint('AuthController signIn Error: $e');
      state = AsyncError(e, st);
    }
  }

  Future<void> signUp(String email, String password, String displayName) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).signUpWithEmail(email, password, displayName);
      state = const AsyncData(null);
    } catch (e, st) {
      debugPrint('AuthController signUp Error: $e');
      state = AsyncError(e, st);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      state = const AsyncData(null);
    } catch (e, st) {
      debugPrint('AuthController signInWithGoogle Error: $e');
      state = AsyncError(e, st);
    }
  }


  Future<void> signOut() async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signOut(),
    );
    state = result.whenData((_) {});
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).sendPasswordResetEmail(email),
    );
    state = result.whenData((_) {});
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).changePassword(currentPassword, newPassword),
    );
    state = result.whenData((_) {});
  }

  Future<void> updateDisplayName(String displayName) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).updateDisplayName(displayName),
    );
    state = result.whenData((_) {});
  }

  Future<void> updateProfileImage(dynamic file) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).updateProfileImage(file),
    );
    state = result.whenData((_) {});
  }

  Future<void> sendEmailVerification() async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).sendEmailVerification(),
    );
    state = result.whenData((_) {});
  }

  Future<void> deleteAccount() async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final user = ref.read(userProvider).value;
      if (user != null) {
        // 1. Disable the account in Firestore
        await ref.read(userServiceProvider).disableAccount(user.uid);
      }
      // 2. Sign out the user
      await ref.read(authRepositoryProvider).signOut();
    });
    state = result.whenData((_) {});
  }
}
