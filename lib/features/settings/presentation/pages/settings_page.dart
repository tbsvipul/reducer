import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:reducer/features/premium/data/datasources/purchase_datasource.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_spacing.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/features/settings/presentation/widgets/settings_tile.dart';
import 'package:reducer/features/settings/presentation/widgets/settings_section_header.dart';
import 'package:reducer/features/settings/presentation/widgets/review_card.dart';
import 'package:reducer/l10n/app_localizations.dart';
import 'package:reducer/core/services/remote_config_service.dart';
import 'package:reducer/features/auth/presentation/providers/auth_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  String get _appStoreUrl => RemoteConfigService().appStoreUrl;

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
    }
  }

  void _shareApp(BuildContext context) {
    SharePlus.instance.share(
      ShareParams(
        text: AppLocalizations.of(context)!.shareAppText(_appStoreUrl),
        subject: 'Reducer',
      ),
    );
  }

  Future<void> _showDeleteAccountDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null || user.isAnonymous) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login before requesting account deletion.'),
          ),
        );
      }
      return;
    }

    final userEmail = user.email ?? '';
    final userId = user.uid;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'A deletion request will be sent to our support team. '
          'Your account will be reviewed and deleted within a few business days.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Request Deletion'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        if (context.mounted) {
          unawaited(
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        await ref
            .read(userServiceProvider)
            .requestAccountDeletion(uid: userId, email: userEmail);

        if (context.mounted) {
          Navigator.pop(context); // Pop loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Deletion request sent successfully.'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // Pop loading
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to send request: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumState = ref.watch(premiumControllerProvider);
    final authUser = ref.watch(authStateProvider).value;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontSize: 20),
        ),
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // ── Premium Section ───────────────────────────────────────────────
          if (!premiumState.isPro) ...[
            SettingsSectionHeader(title: l10n.subscription),

            Card(
              child: ListTile(
                leading: const Icon(Iconsax.crown, color: AppColors.premium),
                title: Text(l10n.upgradeToPro),
                subtitle: Text(l10n.upgradeSubtitle),
                trailing: const Icon(Iconsax.arrow_right_3, size: 16),
                onTap: () => context.push('/premium'),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ] else ...[
            SettingsSectionHeader(title: l10n.subscription),

            Card(
              child: ListTile(
                leading: const Icon(Iconsax.verify, color: AppColors.success),
                title: Text(l10n.proActive),
                subtitle: Text(l10n.supportThanks),
                onTap: () => context.push('/premium'),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],

          const ReviewCard(),
          const SizedBox(height: AppSpacing.xl),

          // ── Support & Feedback ──────────────────────────────────────────────
          SettingsSectionHeader(title: l10n.supportAndFeedback),

          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                SettingsTile(
                  icon: Iconsax.share,
                  title: l10n.shareReducer,
                  onTap: () => _shareApp(context),
                ),
                const Divider(),
                SettingsTile(
                  icon: Iconsax.message_question,
                  title: l10n.contactSupport,
                  onTap: () => _launchUrl(
                    'https://tarurinfotech.base44.app/contact/product?app=reducer',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // ── Preferences ───────────────────────────────────────────────────
          SettingsSectionHeader(title: l10n.preferences),

          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                SettingsTile(
                  icon: Iconsax.language_square,
                  title: l10n.selectLanguage,
                  onTap: () =>
                      context.push('/language-selection?fromSettings=true'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Account Section ──────────────────────────────────────────────
          if (authUser != null && !authUser.isAnonymous) ...[
            const SettingsSectionHeader(title: 'Account'),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  SettingsTile(
                    icon: Iconsax.user_remove,
                    title: 'Delete Account',
                    onTap: () => _showDeleteAccountDialog(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],

          // ── About ───────────────────────────────────────────────────────────
          SettingsSectionHeader(title: l10n.about),

          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                SettingsTile(
                  icon: Iconsax.shield_tick,
                  title: l10n.privacyPolicy,
                  onTap: () => _launchUrl(
                    'https://tarurinfotech.base44.app/privacy/reducer',
                  ),
                ),
                const Divider(),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final version = snapshot.data?.version ?? '1.0.0';
                    final build = snapshot.data?.buildNumber ?? '1';
                    return ListTile(
                      leading: const Icon(Iconsax.info_circle),
                      title: Text(l10n.version),
                      trailing: Text(
                        '$version ($build)',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.onDarkSurfaceVariant
                              : AppColors.onLightSurfaceVariant,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl2),
          Center(
            child: Text(
              l10n.madeWithHeart,
              style: AppTextStyles.bodySmall(context).copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.onDarkSurfaceVariant
                    : AppColors.onLightSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
