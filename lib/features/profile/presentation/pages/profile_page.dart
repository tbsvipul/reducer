import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reducer/features/auth/presentation/controllers/auth_controller.dart';
import 'package:reducer/common/widgets/app_loader.dart';
import 'package:reducer/common/widgets/app_error_widget.dart';
import 'package:reducer/core/theme/app_colors.dart';

import 'package:reducer/features/profile/presentation/widgets/profile_guest_state.dart';
import 'package:reducer/features/profile/presentation/widgets/profile_details_view.dart';

/// Main profile screen that handles different authentication states.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authAsync = ref.watch(authStateChangesProvider);
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: authAsync.when(
        data: (auth) {
          if (auth == null || auth.isAnonymous) {
            return const ProfileGuestState();
          }

          return userAsync.when(
            data: (user) {
              if (user == null) {
                return AppErrorWidget(
                  message: 'Profile data not found.',
                  onRetry: () =>
                      ref.read(authControllerProvider.notifier).signOut(),
                );
              }
              return ProfileDetailsView(user: user);
            },
            loading: () => const AppLoader(
              style: AppLoaderStyle.fullscreen,
              message: 'Loading profile details...',
            ),
            error: (e, s) => AppErrorWidget(
              message: 'Error loading profile: $e',
              onRetry: () => ref.refresh(userProvider),
            ),
          );
        },
        loading: () => const AppLoader(
          style: AppLoaderStyle.fullscreen,
          message: 'Checking authentication...',
        ),
        error: (e, s) => AppErrorWidget(
          message: 'Authentication error: $e',
          onRetry: () => ref.refresh(authStateChangesProvider),
        ),
      ),
    );
  }
}
