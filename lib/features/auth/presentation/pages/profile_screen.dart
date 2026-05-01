import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reducer/features/auth/presentation/controllers/auth_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/core/theme/app_spacing.dart';
import 'package:reducer/core/theme/theme_provider.dart';
import 'package:reducer/l10n/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _pickAndUploadImage(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 512,
      maxHeight: 512,
    );

    if (image != null) {
      final file = File(image.path);
      try {
        await ref
            .read(authControllerProvider.notifier)
            .updateProfileImage(file);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.profileImageUpdated),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.uploadFailed(e.toString()),
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authAsync = ref.watch(authStateChangesProvider);
    final userAsync = ref.watch(userProvider);
    final isLoading = ref.watch(
      authControllerProvider.select((state) => state.isLoading),
    );

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: authAsync.when(
        data: (auth) {
          if (auth == null || auth.isAnonymous) {
            // Trigger redirect if not already happening
            Future.microtask(() {
              if (context.mounted) {
                context.go(
                  '/login?redirect=${Uri.encodeComponent('/profile')}',
                );
              }
            });
            return _buildLoadingState(context, 'Redirecting to login...');
          }

          return userAsync.when(
            data: (user) {
              if (user == null) {
                return _buildErrorState(
                  context,
                  'Profile data not found. Please try logging in again.',
                  ref,
                );
              }

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildSliverHeader(context, ref, user, isDark, isLoading),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.xl,
                      ),
                      child: Column(
                        children: [
                          _buildStatsGrid(context, user, isDark),
                          const SizedBox(height: AppSpacing.xl2),
                          _buildSubscriptionStatusCard(context, user, isDark),
                          const SizedBox(height: AppSpacing.xl2),
                          _buildSettingsSection(context, ref, isDark),
                          const SizedBox(height: AppSpacing.xl2),
                          _buildAccountActions(context, ref, isDark),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () =>
                _buildLoadingState(context, 'Loading profile details...'),
            error: (e, s) =>
                _buildErrorState(context, 'Error loading profile: $e', ref),
          );
        },
        loading: () =>
            _buildLoadingState(context, 'Checking authentication...'),
        error: (e, s) =>
            _buildErrorState(context, 'Authentication error: $e', ref),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 20),
          Text(
            message,
            style: AppTextStyles.bodyMedium(
              context,
            ).copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.danger, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge(context),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).signOut(),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverHeader(
    BuildContext context,
    WidgetRef ref,
    user,
    bool isDark,
    bool isLoading,
  ) {
    return SliverAppBar(
      expandedHeight: 280.h,
      pinned: true,
      stretch: true,
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          alignment: Alignment.center,
          children: [
            // Modern Gradient Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: isDark
                      ? [AppColors.darkSurface, AppColors.darkBackground]
                      : [const Color(0xFFE2E8F0), AppColors.lightBackground],
                ),
              ),
            ),

            // Decorative Blur Circles
            Positioned(
              top: -50.h,
              right: -50.w,
              child:
                  Container(
                        width: 200.r,
                        height: 200.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(
                            alpha: isDark ? 0.1 : 0.05,
                          ),
                        ),
                      )
                      .animate()
                      .scale(duration: 2.seconds, curve: Curves.easeInOut)
                      .fadeIn(),
            ),

            // Profile Main Info
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 48.h),
                // Animated Avatar
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 54.r,
                        backgroundColor: isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.lightSurfaceVariant,
                        backgroundImage: user.profileImageUrl != null
                            ? CachedNetworkImageProvider(user.profileImageUrl!)
                                  as ImageProvider
                            : null,
                        child: user.profileImageUrl == null
                            ? Text(
                                user.name.isNotEmpty
                                    ? user.name[0].toUpperCase()
                                    : 'U',
                                style: AppTextStyles.headlineLarge(context)
                                    .copyWith(
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              )
                            : null,
                      ),
                    ).animate().scale(
                      duration: 600.ms,
                      curve: Curves.easeOutBack,
                    ),

                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: isLoading
                            ? null
                            : () => _pickAndUploadImage(context, ref),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 8),
                            ],
                          ),
                          child: Icon(
                            isLoading ? Icons.sync : Iconsax.camera,
                            color: Colors.white,
                            size: 16.r,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Text(
                  user.name,
                  style: AppTextStyles.headlineSmall(
                    context,
                  ).copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                Text(
                  user.email,
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    color: isDark
                        ? AppColors.onDarkSurfaceVariant
                        : AppColors.onLightSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, user, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _StatsTile(
            label: AppLocalizations.of(context)!.imagesStudio,
            value: user.aiImagesGenerated.toString(),
            icon: Iconsax.image,
            color: AppColors.primary,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: _StatsTile(
            label: AppLocalizations.of(context)!.memberSince,
            value: "${user.createdAt.year}",
            icon: Iconsax.calendar_tick,
            color: AppColors.secondary,
            isDark: isDark,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSubscriptionStatusCard(BuildContext context, user, bool isDark) {
    final isPro = user.subscriptionStatus == 'premium';
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: isPro
            ? const LinearGradient(
                colors: [Color(0xFF1E293B), AppColors.darkBackground],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: !isPro
            ? (isDark ? AppColors.darkSurface : AppColors.lightSurface)
            : null,
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(
          color: isPro
              ? const Color(0xFFFACC15).withValues(alpha: 0.2)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: 1,
        ),
        boxShadow: !isDark && !isPro
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  (isPro
                          ? const Color(0xFFFACC15)
                          : AppColors.onLightSurfaceVariant)
                      .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPro ? Iconsax.crown : Iconsax.user,
              color: isPro
                  ? const Color(0xFFFACC15)
                  : (isDark
                        ? AppColors.onDarkSurfaceVariant
                        : AppColors.onLightSurfaceVariant),
              size: 28.r,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPro
                      ? AppLocalizations.of(context)!.proActive
                      : AppLocalizations.of(context)!.freeMember,
                  style: AppTextStyles.titleLarge(context).copyWith(
                    fontWeight: FontWeight.w900,
                    color: isPro
                        ? Colors.white
                        : (isDark
                              ? AppColors.onDarkSurface
                              : AppColors.onLightSurface),
                  ),
                ),
                Text(
                  isPro
                      ? AppLocalizations.of(context)!.fullAccessUnlocked
                      : AppLocalizations.of(context)!.basicToolsEnabled,
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    color: isDark
                        ? AppColors.onDarkSurfaceVariant
                        : AppColors.onLightSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (!isPro)
            ElevatedButton(
              onPressed: () => context.push('/premium'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(AppLocalizations.of(context)!.goPro),
            )
          else
            IconButton(
              onPressed: () => context.push('/premium'),
              icon: const Icon(Iconsax.arrow_right_3, color: Colors.white24),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSettingsSection(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(
          label: AppLocalizations.of(context)!.preferences,
          isDark: isDark,
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(children: [_ThemeSegmentedPicker(isDark: isDark)]),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildAccountActions(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
  ) {
    return Column(
      children: [
        _ProfileTile(
          icon: Iconsax.logout,
          label: AppLocalizations.of(context)!.logOut,
          color: AppColors.error,
          isDark: isDark,
          onTap: () => _showLogoutDialog(context, ref),
        ),
        const SizedBox(height: AppSpacing.lg),
        _ProfileTile(
          icon: Iconsax.user_remove,
          label: AppLocalizations.of(context)!.deleteAccount,
          color: AppColors.error,
          isDark: isDark,
          onTap: () => _showDeleteAccountDialog(context, ref),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          AppLocalizations.of(context)!.appVersionLabel("1.5.0"),
          style: TextStyle(
            color: isDark
                ? AppColors.onDarkSurfaceVariant
                : AppColors.onLightSurfaceVariant,
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 700.ms);
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteAccount),
        content: Text(AppLocalizations.of(context)!.deleteAccountConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(authControllerProvider.notifier).deleteAccount();
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  Navigator.pop(context);
                }
              }
            },
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.logOut),
        content: Text(AppLocalizations.of(context)!.logOutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.stay),
          ),
          TextButton(
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
              Navigator.pop(context);
            },
            child: Text(
              AppLocalizations.of(context)!.logOut,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatsTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: !isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: AppTextStyles.headlineSmall(
              context,
            ).copyWith(fontWeight: FontWeight.w900),
          ),
          Text(
            label,
            style: AppTextStyles.labelSmall(
              context,
            ).copyWith(color: isDark ? Colors.white54 : Colors.black45),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          color: isDark ? Colors.white24 : Colors.black26,
        ),
      ),
    );
  }
}

class _ThemeSegmentedPicker extends ConsumerWidget {
  final bool isDark;
  const _ThemeSegmentedPicker({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeModeProvider);
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<ThemeMode>(
        segments: [
          ButtonSegment(
            value: ThemeMode.light,
            label: Text(AppLocalizations.of(context)!.light),
            icon: const Icon(Iconsax.sun_1, size: 16),
          ),
          ButtonSegment(
            value: ThemeMode.system,
            label: Text(AppLocalizations.of(context)!.auto),
            icon: const Icon(Iconsax.setting, size: 16),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            label: Text(AppLocalizations.of(context)!.dark),
            icon: const Icon(Iconsax.moon, size: 16),
          ),
        ],
        selected: {currentTheme},
        onSelectionChanged: (set) =>
            ref.read(themeModeProvider.notifier).setThemeMode(set.first),
        style: SegmentedButton.styleFrom(
          backgroundColor: Colors.transparent,
          selectedBackgroundColor: AppColors.primary,
          selectedForegroundColor: Colors.white,
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      trailing: const Icon(Iconsax.arrow_right_3, size: 16, color: Colors.grey),
    );
  }
}
