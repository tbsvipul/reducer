import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/design_tokens.dart';
import '../../core/theme.dart';
import '../../models/ad_state.dart';
import '../../widgets/banner_ad_widget.dart';
import '../../providers/premium_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adState = ref.watch(adStateProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.setting),
          onPressed: () => context.push('/settings'),
        ),
        title: const Text('ImageMaster Pro'),
        actions: [
          if (!ref.watch(premiumProvider).isPro)
            IconButton(
              icon: const Icon(Iconsax.crown, color: Colors.orange),
              onPressed: () => context.push('/premium'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Banner Ad
            const BannerAdWidget(),
            const SizedBox(height: 16),

            // Main Selection Card
            _buildMainActionCard(context, ref),

            const SizedBox(height: 24),

            // Tools Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildToolCard(
                  context,
                  ref,
                  title: 'Bulk Process',
                  subtitle: 'Up to 50 images',
                  icon: Iconsax.grid_5,
                  route: '/bulk-editor',
                ),
                _buildToolCard(
                  context,
                  ref,
                  title: 'EXIF Eraser',
                  subtitle: 'Clean image metadata',
                  icon: Iconsax.shield_tick,
                  route: '/exif-eraser',
                ),
                _buildToolCard(
                  context,
                  ref,
                  title: 'Gallery',
                  subtitle: 'Past edits',
                  icon: Iconsax.gallery,
                  route: '/gallery',
                ),
                if (!ref.watch(premiumProvider).isPro)
                  _buildToolCard(
                    context,
                    ref,
                    title: 'Go Premium',
                    subtitle: 'Ad-free experience',
                    icon: Iconsax.crown,
                    route: '/premium',
                    isHighlight: true,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainActionCard(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showUploadOptions(context, ref),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: AppTheme.neumorphicDecoration(context).copyWith(
          border: Border.all(color: DesignTokens.primaryBlue.withOpacity(0.3), width: 2),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: DesignTokens.accentBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.image, size: 48, color: DesignTokens.primaryBlue),
            ),
            const SizedBox(height: 24),
            const Text(
              'Single Image Process',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Resize, Compress or Convert one image',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String route,
    bool isHighlight = false,
  }) {
    return GestureDetector(
      onTap: () async {
        final adState = ref.read(adStateProvider);
        await adState.onFeatureClick(
          context: context,
          onComplete: () => context.push(route),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.neumorphicDecoration(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: isHighlight ? Colors.orange : DesignTokens.primaryBlue,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  void _showUploadOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Upload Image',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildUploadOption(
                context,
                ref,
                icon: Iconsax.image,
                label: 'From Gallery',
                route: '/single-editor',
              ),
              _buildUploadOption(
                context,
                ref,
                icon: Iconsax.camera,
                label: 'Camera',
                route: '/single-editor',
              ),
              _buildUploadOption(
                context,
                ref,
                icon: Iconsax.link,
                label: 'From URL',
                route: '/single-editor',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUploadOption(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String label,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon, color: DesignTokens.primaryBlue),
      title: Text(label),
      onTap: () async {
        Navigator.pop(context);
        final adState = ref.read(adStateProvider);
        await adState.onFeatureClick(
          context: context,
          onComplete: () => context.push(route),
        );
      },
      trailing: const Icon(Iconsax.arrow_right_3, size: 16),
    );
  }
}
