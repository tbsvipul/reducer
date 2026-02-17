import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/design_tokens.dart';
import '../../core/theme.dart';
import '../../widgets/banner_ad_widget.dart';
import '../../providers/premium_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          const BannerAdWidget(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (!ref.watch(premiumProvider).isPro)
                  _buildSettingsCard(
                    context,
                    title: 'Get Ads Free Version',
                    subtitle: 'Enjoy professional tools without interruptions',
                    icon: Iconsax.crown,
                    iconColor: Colors.orange,
                    onTap: () => context.push('/premium'),
                  ),
                const SizedBox(height: 16),
                _buildSettingsCard(
                  context,
                  title: 'Rate Us',
                  subtitle: 'Support us by leaving a review',
                  icon: Iconsax.star,
                  iconColor: Colors.yellow[700]!,
                  onTap: () async {
                    final url = Uri.parse('https://play.google.com/store/apps/details?id=com.imagemaster.pro'); // Placeholder
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildSettingsCard(
                  context,
                  title: 'Share App',
                  subtitle: 'Tell your friends about ImageMaster Pro',
                  icon: Iconsax.share,
                  iconColor: DesignTokens.primaryBlue,
                  onTap: () {
                    Share.share('Check out ImageMaster Pro - The ultimate image processing tool! https://play.google.com/store/apps/details?id=com.imagemaster.pro');
                  },
                ),
                const SizedBox(height: 16),
                _buildSettingsCard(
                  context,
                  title: 'Privacy Policy',
                  subtitle: 'How we handle your data',
                  icon: Iconsax.security_safe,
                  iconColor: Colors.green,
                  onTap: () => context.push('/privacy-policy'),
                ),
                const SizedBox(height: 32),
                const Center(
                  child: Text(
                    'Version 1.0.0',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.neumorphicDecoration(context),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Iconsax.arrow_right_3, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
