import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:reducer/l10n/app_localizations.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/core/ads/ad_manager.dart';
import 'package:reducer/features/home/presentation/widgets/tool_card.dart';

/// Section on the home screen for quick access to primary tools.
class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, l10n),
        const _HeroActionCard(),
        SizedBox(height: AppDimensions.lg.h),
        _SecondaryActionsGrid(l10n: l10n),
      ],
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSectionHeader(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l10n.quickStart, style: AppTextStyles.titleLarge(context)),
        TextButton(
          onPressed: () {}, // Future: Lead to a guide
          child: Text(
            l10n.howItWorks,
            style: AppTextStyles.labelSmall(context).copyWith(
              color: AppColors.primary,
              fontSize: 11.sp,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroActionCard extends StatelessWidget {
  const _HeroActionCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      height: 160.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl.r),
        boxShadow: AppColors.buttonShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => AdManager().showInterstitialAd(
            onComplete: () => context.go('/single-editor'),
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl.r),
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.xl.r),
            child: Stack(
              children: [
                _buildContent(context, l10n),
                _buildBackgroundIcon(),
                _buildTrailingIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(AppDimensions.sm.r),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Iconsax.image, color: Colors.white, size: 32.r),
        ),
        SizedBox(height: AppDimensions.md.h),
        Text(
          l10n.optimizeImage,
          style: AppTextStyles.titleLarge(context).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          l10n.optimizeSubtitle,
          style: AppTextStyles.bodySmall(context).copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundIcon() {
    return Positioned(
      right: -20.w,
      bottom: -20.h,
      child: Icon(
        Iconsax.magicpen,
        size: 140.r,
        color: Colors.white.withValues(alpha: 0.1),
      ),
    );
  }

  Widget _buildTrailingIcon() {
    return const Positioned(
      right: 0,
      top: 0,
      child: Icon(Iconsax.arrow_right_1, color: Colors.white, size: 24),
    );
  }
}

class _SecondaryActionsGrid extends StatelessWidget {
  const _SecondaryActionsGrid({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ToolCard(
            title: l10n.convert,
            subtitle: l10n.convertSubtitle,
            icon: Iconsax.refresh,
            color: AppColors.secondary,
            onTap: () => AdManager().showInterstitialAd(
              onComplete: () => context.go('/single-editor'),
            ),
          ),
        ),
        SizedBox(width: AppDimensions.lg.w),
        Expanded(
          child: ToolCard(
            title: l10n.history,
            subtitle: l10n.historySubtitle,
            icon: Iconsax.clock,
            color: AppColors.premium,
            onTap: () => AdManager().showInterstitialAd(
              onComplete: () => context.go('/gallery'),
            ),
          ),
        ),
      ],
    );
  }
}

