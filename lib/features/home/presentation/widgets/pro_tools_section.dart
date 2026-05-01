import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reducer/common/widgets/app_button.dart';
import 'package:reducer/common/widgets/app_dialog.dart';
import 'package:reducer/core/ads/ad_manager.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/l10n/app_localizations.dart';
import 'feature_list_tile.dart';

/// Section on the home screen displaying advanced/pro tools.
class ProToolsSection extends StatelessWidget {
  const ProToolsSection({
    super.key,
    required this.isPro,
    required this.isLoggedIn,
  });

  final bool isPro;
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, l10n),
            const SizedBox(height: AppDimensions.lg),
            FeatureListTile(
              title: l10n.bulkProcessing,
              subtitle: l10n.bulkSubtitle,
              icon: Iconsax.layer,
              isPro: true,
              hasAccess: isPro,
              onTap: () => _handleProFeature(
                context,
                isPro,
                isLoggedIn,
                '/bulk-editor',
                l10n,
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            FeatureListTile(
              title: l10n.exifEraser,
              subtitle: l10n.exifSubtitle,
              icon: Iconsax.shield_tick,
              isPro: false,
              hasAccess: true,
              onTap: () => AdManager().showInterstitialAd(
                onComplete: () => context.push('/exif-eraser'),
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            FeatureListTile(
              title: l10n.viewHistory,
              subtitle: l10n.viewHistorySubtitle,
              icon: Iconsax.clock,
              isPro: false,
              hasAccess: true,
              onTap: () => AdManager().showInterstitialAd(
                onComplete: () => context.go('/gallery'),
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(delay: 200.ms, duration: 400.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Text(l10n.advancedTools, style: AppTextStyles.titleLarge(context)),
        const Spacer(),
        if (!isPro)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.sm,
              vertical: AppDimensions.xs2,
            ),
            decoration: BoxDecoration(
              color: AppColors.premiumContainer,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Text(
              l10n.proBadge,
              style: AppTextStyles.badgeLabel(
                context,
              ).copyWith(color: AppColors.premium),
            ),
          ),
      ],
    );
  }

  void _handleProFeature(
    BuildContext context,
    bool isPro,
    bool isLoggedIn,
    String route,
    AppLocalizations l10n,
  ) {
    if (isPro) {
      context.go(route);
      return;
    }

    if (!isLoggedIn) {
      _showLoginRequiredDialog(context, l10n);
      return;
    }

    _showPremiumRequiredDialog(context, l10n);
  }

  void _showPremiumRequiredDialog(BuildContext context, AppLocalizations l10n) {
    AppDialog.show(
      context,
      title: l10n.unlockReducerPro,
      message: l10n.proDescription,
      confirmLabel: l10n.upgradeToPro,
      cancelLabel: l10n.maybeLater,
      type: AppDialogType.info,
      onConfirm: () => context.push('/premium'),
    );
  }

  void _showLoginRequiredDialog(BuildContext context, AppLocalizations l10n) {
    AppDialog.show(
      context,
      title: l10n.signInRequired,
      message: l10n.signInRequiredDescription,
      customActions: [
        AppButton(
          label: l10n.signInNow,
          onPressed: () {
            Navigator.pop(context);
            context.push('/login');
          },
        ),
        AppButton(
          label: l10n.createAccount,
          style: AppButtonStyle.outline,
          onPressed: () {
            Navigator.pop(context);
            context.push('/register');
          },
        ),
        AppButton(
          label: l10n.maybeLater,
          style: AppButtonStyle.ghost,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
