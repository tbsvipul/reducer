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
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/features/settings/presentation/widgets/settings_tile.dart';
import 'package:reducer/features/settings/presentation/widgets/settings_section_header.dart';
import 'package:reducer/features/settings/presentation/widgets/review_card.dart';
import 'package:reducer/l10n/app_localizations.dart';
import 'package:reducer/core/services/remote_config_service.dart';
import 'package:reducer/common/widgets/app_dialog.dart';
import 'package:reducer/common/widgets/app_snackbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reducer/features/auth/presentation/controllers/auth_controller.dart';

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
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null || user.isAnonymous) {
      debugPrint('Account Deletion Error: Please login before requesting account deletion.');
      return;
    }

    unawaited(AppDialog.show(
      context,
      title: 'Delete Account?',
      message: 'A deletion request will be sent to our support team. '
          'Your account will be reviewed and deleted within a few business days.',
      confirmLabel: 'Request Deletion',
      cancelLabel: 'Cancel',
      type: AppDialogType.error,
      onConfirm: () async {
        try {
          // Show non-dismissible loading dialog using AppDialog
          AppDialog.showLoading(context);

          await ref.read(authRepositoryProvider).deleteAccount();

          if (context.mounted) {
            Navigator.pop(context); // Pop loading
            AppSnackbar.show(context, 'Deletion request sent successfully.');
          }
        } catch (e) {
          if (context.mounted) {
            Navigator.pop(context); // Pop loading
            debugPrint('Account Deletion Error: $e');
            AppSnackbar.show(context, 'Failed to send deletion request.', type: AppSnackbarType.error);
          }
        }
      },
    )
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumState = ref.watch(premiumControllerProvider);
    final authUser = ref.watch(authStateChangesProvider).value;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontSize: 20.sp),
        ),
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        padding: EdgeInsets.all(AppDimensions.lg.r),
        children: [
          // ── Premium Section ───────────────────────────────────────────────
          if (!premiumState.isPro) ...[
            SettingsSectionHeader(title: l10n.subscription),

            Card(
              child: ListTile(
                leading: Icon(Iconsax.crown, color: AppColors.premium, size: 24.r),
                title: Text(l10n.upgradeToPro, style: TextStyle(fontSize: 16.sp)),
                subtitle: Text(l10n.upgradeSubtitle, style: TextStyle(fontSize: 14.sp)),
                trailing: Icon(Iconsax.arrow_right_3, size: 16.r),
                onTap: () => context.push('/premium'),
              ),
            ),
            SizedBox(height: AppDimensions.xl.h),
          ] else ...[
            SettingsSectionHeader(title: l10n.subscription),

            Card(
              child: ListTile(
                leading: Icon(Iconsax.verify, color: AppColors.success, size: 24.r),
                title: Text(l10n.proActive, style: TextStyle(fontSize: 16.sp)),
                subtitle: Text(l10n.supportThanks, style: TextStyle(fontSize: 14.sp)),
                onTap: () => context.push('/premium'),
              ),
            ),
            SizedBox(height: AppDimensions.xl.h),
          ],

          const ReviewCard(),
          SizedBox(height: AppDimensions.xl.h),

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
          SizedBox(height: AppDimensions.xl.h),
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
          SizedBox(height: AppDimensions.xl.h),

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
            SizedBox(height: AppDimensions.xl.h),
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
                      leading: Icon(Iconsax.info_circle, size: 24.r),
                      title: Text(l10n.version, style: TextStyle(fontSize: 16.sp)),
                      trailing: Text(
                        '$version ($build)',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.onDarkSurfaceVariant
                              : AppColors.onLightSurfaceVariant,
                          fontSize: 14.sp,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: AppDimensions.xl2.h),
          Center(
            child: Text(
              l10n.madeWithHeart,
              style: AppTextStyles.bodySmall(context).copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.onDarkSurfaceVariant
                    : AppColors.onLightSurfaceVariant,
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
