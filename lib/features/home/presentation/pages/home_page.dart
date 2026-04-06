import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import 'package:reducer/features/premium/data/datasources/purchase_datasource.dart';
import 'package:reducer/core/widgets/ads/banner_ad_widget.dart';
import 'package:reducer/core/ads/ad_manager.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_spacing.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumState = ref.watch(premiumControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Custom App Bar ────────────────────────────────────────────────
            SliverAppBar(
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
              expandedHeight: 80,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                title: Text(
                  'ImageMaster',
                  style: AppTextStyles.headlineSmall(context),
                ),
              ),
              actions: [
                if (!premiumState.isPro)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.premium,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 0),
                          minimumSize: const Size(0, 36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                          ),
                        ),
                        onPressed: () => context.push('/premium'),
                        icon: const Icon(Iconsax.crown, size: AppSpacing.iconSm),
                        label: Text('PRO', style: AppTextStyles.labelMedium(context).copyWith(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Iconsax.setting_2),
                  onPressed: () => context.push('/settings'),
                  tooltip: 'Settings',
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
            ),

            // ── Banner Ad ─────────────────────────────────────────────────────
            const SliverToBoxAdapter(
              child: BannerAdWidget(),
            ),

            // ── Main Content ──────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(context, premiumState.isPro),
                  const SizedBox(height: AppSpacing.xl2),
                  _buildQuickActions(context),
                  const SizedBox(height: AppSpacing.xl3),
                  _buildProTools(context, premiumState.isPro),
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AdManager().showInterstitialAd(
            onComplete: () => context.push('/single-editor'),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Iconsax.edit),
        label: Text('New Edit', style: AppTextStyles.buttonText(context)),
      )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .shimmer(delay: 2000.ms, duration: 1500.ms, color: Colors.white.withValues(alpha: 0.2)),
    );
  }

  Widget _buildHeader(BuildContext context, bool isPro) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: AppTheme.cardDecoration(context),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.magic_star, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready to create?',
                  style: AppTextStyles.titleMedium(context),
                ),
                const SizedBox(height: AppSpacing.xs2),
                Text(
                  'Select a tool below to get started.',
                  style: AppTextStyles.bodyMedium(context),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Essential Tools', style: AppTextStyles.titleLarge(context)),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _ToolCard(
                title: 'Compress',
                subtitle: 'Reduce size',
                icon: Iconsax.document_download,
                color: AppColors.primary,
                onTap: () => AdManager().showInterstitialAd(
                  onComplete: () => context.push('/single-editor'),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _ToolCard(
                title: 'Convert',
                subtitle: 'Change format',
                icon: Iconsax.refresh,
                color: AppColors.secondary,
                onTap: () => AdManager().showInterstitialAd(
                  onComplete: () => context.push('/single-editor'),
                ),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildProTools(BuildContext context, bool isPro) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Advanced Tools', style: AppTextStyles.titleLarge(context)),
            const Spacer(),
            if (!isPro)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs2),
                decoration: BoxDecoration(
                  color: AppColors.premiumContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text('PRO', style: AppTextStyles.badgeLabel(context).copyWith(color: AppColors.premium)),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _FeatureListTile(
          title: 'Bulk Processing',
          subtitle: 'Process up to 50 images at once',
          icon: Iconsax.layer,
          isPro: true,
          hasAccess: isPro,
          onTap: () => _handleProFeature(context, isPro, '/bulk-editor'),
        ),
        const SizedBox(height: AppSpacing.md),
        _FeatureListTile(
          title: 'EXIF Eraser',
          subtitle: 'Remove metadata for privacy',
          icon: Iconsax.shield_tick,
          isPro: false,
          hasAccess: true,
          onTap: () => AdManager().showInterstitialAd(
            onComplete: () => context.push('/exif-eraser'),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _FeatureListTile(
          title: 'Edit History',
          subtitle: 'View and export past edits',
          icon: Iconsax.clock,
          isPro: false,
          hasAccess: true,
          onTap: () => AdManager().showInterstitialAd(
            onComplete: () => context.push('/gallery'),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  void _handleProFeature(BuildContext context, bool isPro, String route) {
    if (isPro) {
      context.push(route);
    } else {
      _showPremiumRequiredDialog(context);
    }
  }

  void _showPremiumRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Iconsax.crown, color: AppColors.premium, size: 48),
        title: const Text('Premium Feature'),
        content: const Text(
          'Bulk processing requires a ImageMaster Pro subscription. Upgrade now to unlock all features without ads.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.premium),
            onPressed: () {
              Navigator.pop(context);
              context.push('/premium');
            },
            child: const Text('Upgrade to Pro'),
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ToolCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: AppTheme.cardDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(icon, color: color, size: AppSpacing.iconLg),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: AppTextStyles.titleMedium(context),
              ),
              const SizedBox(height: AppSpacing.xs2),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isPro;
  final bool hasAccess;
  final VoidCallback onTap;

  const _FeatureListTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isPro,
    required this.hasAccess,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: AppTheme.cardDecoration(context),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Icon(
            icon,
            color: isPro && !hasAccess ? Colors.grey : AppColors.primary,
          ),
        ),
        title: Row(
          children: [
            Text(title),
            if (isPro && !hasAccess) ...[
              const SizedBox(width: AppSpacing.sm),
              const Icon(Iconsax.lock, size: 14, color: Colors.grey),
            ],
          ],
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Iconsax.arrow_right_3, size: 16),
      ),
    );
  }
}
