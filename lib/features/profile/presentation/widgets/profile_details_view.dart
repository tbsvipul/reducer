import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:reducer/features/auth/domain/models/user_model.dart';
import 'package:reducer/features/auth/presentation/controllers/auth_controller.dart';
import 'package:reducer/common/widgets/app_image.dart';
import 'package:reducer/common/widgets/app_dialog.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/l10n/app_localizations.dart';

import 'profile_stats_tile.dart';
import 'profile_list_tile.dart';
import 'theme_segmented_picker.dart';

class ProfileDetailsView extends ConsumerWidget {
  final AppUser user;

  const ProfileDetailsView({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authControllerProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _ProfileSliverHeader(user: user, isLoading: authState.isLoading),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.xl.w,
              vertical: AppDimensions.xl.h,
            ),
            child: Column(
              children: [
                _ProfileStatsGrid(user: user, isDark: isDark),
                SizedBox(height: AppDimensions.xl2.h),
                _SubscriptionStatusCard(user: user, isDark: isDark),
                SizedBox(height: AppDimensions.xl2.h),
                _PreferencesSection(isDark: isDark),
                SizedBox(height: AppDimensions.xl2.h),
                _AccountActionsSection(user: user, isDark: isDark),
                SizedBox(height: 120.h),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileSliverHeader extends ConsumerWidget {
  final AppUser user;
  final bool isLoading;

  const _ProfileSliverHeader({required this.user, required this.isLoading});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: 280.h,
      pinned: true,
      stretch: true,
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        background: Stack(
          alignment: Alignment.center,
          children: [
            _buildBackground(isDark),
            _buildDecorativeCircle(isDark),
            _buildProfileInfo(context, ref, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? AppColors.darkSurfaceGradient
              : [const Color(0xFFE2E8F0), AppColors.lightBackground],
        ),
      ),
    );
  }

  Widget _buildDecorativeCircle(bool isDark) {
    return Positioned(
      top: -50.h,
      right: -50.w,
      child: Container(
        width: 200.r,
        height: 200.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: isDark ? 0.1 : 0.05),
        ),
      ).animate().scale(duration: 2.seconds, curve: Curves.easeInOut).fadeIn(),
    );
  }

  Widget _buildProfileInfo(BuildContext context, WidgetRef ref, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 48.h),
        _AvatarSection(user: user, isLoading: isLoading),
        SizedBox(height: AppDimensions.xl.h),
        _DisplayNameSection(user: user),
        Text(
          user.email,
          style: AppTextStyles.bodyMedium(context).copyWith(
            color: isDark ? AppColors.onDarkSurfaceVariant : AppColors.onLightSurfaceVariant,
            fontWeight: FontWeight.w500,
            fontSize: 14.sp,
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
      ],
    );
  }
}

class _AvatarSection extends ConsumerWidget {
  final AppUser user;
  final bool isLoading;

  const _AvatarSection({required this.user, required this.isLoading});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(AppDimensions.xs.r),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 2.r,
            ),
          ),
          child: AppImage(
            url: user.photoUrl,
            width: 108,
            height: 108,
            borderRadius: 54,
            errorWidget: Container(
              width: 108.r,
              height: 108.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
              ),
              child: Center(
                child: Text(
                  (user.displayName != null && user.displayName!.isNotEmpty)
                      ? user.displayName![0].toUpperCase()
                      : 'U',
                  style: AppTextStyles.headlineLarge(context).copyWith(
                    color: isDark ? AppColors.onDarkSurface : AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 32.sp,
                  ),
                ),
              ),
            ),
          ),
        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: isLoading ? null : () => _pickImage(context, ref),
            child: Container(
              padding: EdgeInsets.all(AppDimensions.sm.r),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: AppDimensions.sm.r,
                  )
                ],
              ),
              child: Icon(
                isLoading ? Icons.sync : Iconsax.camera,
                color: AppColors.onPrimary,
                size: AppDimensions.iconSm.r,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(BuildContext context, WidgetRef ref) async {
    // For now, we use a placeholder or handle the picking logic
    // In a real app, you'd use ImagePicker here.
    // ref.read(authControllerProvider.notifier).updateProfileImage(pickedFile);
  }
}

class _DisplayNameSection extends ConsumerWidget {
  final AppUser user;

  const _DisplayNameSection({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showEditNameDialog(context, ref),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            user.displayName ?? 'No Name',
            style: AppTextStyles.headlineSmall(context).copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              fontSize: 24.sp,
            ),
          ),
          SizedBox(width: AppDimensions.sm.w),
          Icon(
            Iconsax.edit_2,
            size: AppDimensions.iconSm.r,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.onDarkSurfaceVariant
                : AppColors.onLightSurfaceVariant,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Future<void> _showEditNameDialog(BuildContext context, WidgetRef ref) async {
    // Implementation using AppDialog and controller
  }
}

class _ProfileStatsGrid extends StatelessWidget {
  final AppUser user;
  final bool isDark;

  const _ProfileStatsGrid({required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: ProfileStatsTile(
            label: l10n.imagesStudio,
            value: user.aiImagesGenerated.toString(),
            icon: Iconsax.image,
            color: AppColors.primary,
            isDark: isDark,
          ),
        ),
        SizedBox(width: AppDimensions.lg.w),
        Expanded(
          child: ProfileStatsTile(
            label: l10n.memberSince,
            value: "${user.createdAt.year}",
            icon: Iconsax.calendar_tick,
            color: AppColors.secondary,
            isDark: isDark,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }
}

class _SubscriptionStatusCard extends StatelessWidget {
  final AppUser user;
  final bool isDark;

  const _SubscriptionStatusCard({required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isPro = user.subscriptionStatus == 'premium';
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(AppDimensions.xl2.r),
      decoration: BoxDecoration(
        gradient: isPro
            ? const LinearGradient(
                colors: AppColors.darkSurfaceGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: !isPro ? (isDark ? AppColors.darkSurface : AppColors.lightSurface) : null,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl2.r),
        border: Border.all(
          color: isPro
              ? AppColors.premium.withValues(alpha: 0.2)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: 1.r,
        ),
        boxShadow: !isDark && !isPro ? AppColors.cardShadowLight : null,
      ),
      child: Row(
        children: [
          _buildIcon(isPro, isDark),
          SizedBox(width: AppDimensions.xl.w),
          _buildTextContent(context, isPro, isDark, l10n),
          _buildActionButton(context, isPro, l10n),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildIcon(bool isPro, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.md.r),
      decoration: BoxDecoration(
        color: (isPro ? AppColors.premium : AppColors.onLightSurfaceVariant)
            .withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isPro ? Iconsax.crown : Iconsax.user,
        color: isPro
            ? AppColors.premium
            : (isDark ? AppColors.onDarkSurfaceVariant : AppColors.onLightSurfaceVariant),
        size: AppDimensions.iconXl.r,
      ),
    );
  }

  Widget _buildTextContent(BuildContext context, bool isPro, bool isDark, AppLocalizations l10n) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isPro ? l10n.proActive : l10n.freeMember,
            style: AppTextStyles.titleLarge(context).copyWith(
              fontWeight: FontWeight.w900,
              color: isPro ? AppColors.onPremium : (isDark ? AppColors.onDarkSurface : AppColors.onLightSurface),
              fontSize: 18.sp,
            ),
          ),
          Text(
            isPro ? l10n.fullAccessUnlocked : l10n.basicToolsEnabled,
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: isDark ? AppColors.onDarkSurfaceVariant : AppColors.onLightSurfaceVariant,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, bool isPro, AppLocalizations l10n) {
    if (!isPro) {
      return ElevatedButton(
        onPressed: () => context.push('/premium'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r)),
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.lg.w, vertical: AppDimensions.sm.h),
        ),
        child: Text(l10n.goPro, style: TextStyle(fontSize: 14.sp)),
      );
    }
    return IconButton(
      onPressed: () => context.push('/premium'),
      icon: Icon(Iconsax.arrow_right_3, color: AppColors.onPremium.withValues(alpha: 0.24), size: AppDimensions.iconLg),
    );
  }
}

class _PreferencesSection extends StatelessWidget {
  final bool isDark;

  const _PreferencesSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: AppLocalizations.of(context)!.preferences, isDark: isDark),
        SizedBox(height: AppDimensions.lg.h),
        Container(
          padding: EdgeInsets.all(AppDimensions.md.r),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl2.r),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: const ThemeSegmentedPicker(),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms);
  }
}

class _AccountActionsSection extends ConsumerWidget {
  final AppUser user;
  final bool isDark;

  const _AccountActionsSection({required this.user, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        if (!user.isEmailVerified) ...[
          ProfileListTile(
            icon: Iconsax.verify,
            label: 'Verify Email',
            color: AppColors.warning,
            isDark: isDark,
            onTap: () => ref.read(authControllerProvider.notifier).sendEmailVerification(),
          ),
          SizedBox(height: AppDimensions.lg.h),
        ],
        ProfileListTile(
          icon: Iconsax.logout,
          label: l10n.logOut,
          color: AppColors.error,
          isDark: isDark,
          onTap: () => _logout(context, ref, l10n),
        ),
        SizedBox(height: AppDimensions.lg.h),
        ProfileListTile(
          icon: Iconsax.user_remove,
          label: l10n.deleteAccount,
          color: AppColors.error,
          isDark: isDark,
          onTap: () => _deleteAccount(context, ref, l10n),
        ),
        SizedBox(height: AppDimensions.lg.h),
        Text(
          l10n.appVersionLabel("1.5.0"),
          style: AppTextStyles.labelSmall(context).copyWith(
            color: isDark ? AppColors.onDarkSurfaceVariant : AppColors.onLightSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 700.ms);
  }

  void _logout(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    AppDialog.show(
      context,
      title: l10n.logOut,
      message: l10n.logoutConfirm,
      confirmLabel: l10n.logOut,
      cancelLabel: l10n.stay,
      type: AppDialogType.confirm,
      onConfirm: () => ref.read(authControllerProvider.notifier).signOut(),
    );
  }

  void _deleteAccount(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    AppDialog.show(
      context,
      title: l10n.deleteAccount,
      message: l10n.deleteAccountConfirmation,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      type: AppDialogType.error,
      onConfirm: () => ref.read(authControllerProvider.notifier).deleteAccount(),
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
      padding: EdgeInsets.only(left: AppDimensions.sm.w),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5.w,
          color: isDark ? Colors.white.withValues(alpha: 0.24) : Colors.black.withValues(alpha: 0.26),
        ),
      ),
    );
  }
}
