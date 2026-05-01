import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_spacing.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/l10n/app_localizations.dart';

class LoginRequiredDialog extends StatelessWidget {
  const LoginRequiredDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl2),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl2),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          boxShadow: isDark
              ? AppColors.cardShadowDark
              : AppColors.cardShadowLight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.user_octagon,
                color: AppColors.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Title
            Text(
              AppLocalizations.of(context)!.signInRequired,
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineSmall(context).copyWith(
                color: isDark ? AppColors.onDarkSurface : AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Description
            Text(
              AppLocalizations.of(context)!.signInRequiredDescription,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: isDark
                    ? AppColors.onDarkSurfaceVariant
                    : AppColors.onLightSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl2),

            // Primary Action: Login
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/login');
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                ),
                child: Text(AppLocalizations.of(context)!.signInNow),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Secondary Action: Register
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/register');
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.createAccount),
              ),
            ),

            // Tertiary Action: Close
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.of(context)!.maybeLater,
                style: TextStyle(
                  color: isDark
                      ? AppColors.onDarkSurfaceVariant
                      : AppColors.onLightSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
