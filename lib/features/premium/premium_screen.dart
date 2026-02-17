import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../core/design_tokens.dart';
import '../../core/theme.dart';
import '../../providers/premium_provider.dart';
import '../../services/purchase_service.dart';
import '../../ads/ad_service.dart';

final offeringsProvider = FutureProvider<Offerings?>((ref) async {
  return await PurchaseService.getOfferings();
});

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(premiumProvider);
    
    // Sync AdService premium status
    AdService.isPremium = state.isPro;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1A2E), // Deep Midnight
                  Color(0xFF16213E), // Dark Navy
                  Color(0xFF0F3460), // Royal Blue
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Iconsax.close_circle, color: Colors.white70, size: 28),
                      onPressed: () => context.pop(),
                    ),
                    TextButton(
                      onPressed: () => ref.read(premiumProvider.notifier).restore(),
                      child: const Text('Restore', style: TextStyle(color: Colors.white54, fontSize: 13)),
                    ),
                  ],
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Header
                        const Icon(Iconsax.crown1, size: 48, color: Colors.orange)
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .shimmer(delay: 1.seconds, duration: 1500.ms)
                            .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
                        const SizedBox(height: 8),
                        const Text(
                          'ImageMaster Pro',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ).animate().fadeIn(),
                        const Text(
                          'UNLIMITED ACCESS',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.orange, letterSpacing: 2),
                        ).animate().fadeIn(delay: 200.ms),

                        const SizedBox(height: 16),

                        // Features List
                        _buildBenefitSection(),

                        const Spacer(),

                        // Package Selection
                        if (state.isPro)
                          _buildProActiveBadge(state)
                        else if (state.isLoading)
                          const Center(child: CircularProgressIndicator(color: Colors.orange))
                        else if (state.errorMessage != null && !PurchaseService.isMockMode)
                          _buildErrorState(ref, state.errorMessage!)
                        else
                          _buildPackageSelection(ref, state),

                        const SizedBox(height: 16),

                        // Main CTA
                        if (!state.isPro) _buildSubscribeButton(context, ref, state),

                        const SizedBox(height: 12),
                        const Text(
                          'Subscription will renew automatically. Cancel anytime.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white38, fontSize: 10),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitSection() {
    return Column(
      children: [
        _buildBenefitRow(Iconsax.flash, 'Ad-Free Workspace'),
        _buildBenefitRow(Iconsax.image, 'No Watermarks'),
        _buildBenefitRow(Iconsax.grid_5, 'Unlimited Bulk Edits'),
        _buildBenefitRow(Iconsax.security_user, 'Advanced Metadata Control'),
      ],
    ).animate().fadeIn(delay: 400.ms).moveY(begin: 10, end: 0);
  }

  Widget _buildBenefitRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange, size: 16),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildProActiveBadge(PremiumState state) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Iconsax.verify, color: Colors.green, size: 40),
          const SizedBox(height: 12),
          const Text(
            'Pro Status Active',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildDetailRow('Active Plan', 'Lifetime Unlock'),
          _buildDetailRow('Purchased', 'Feb 15, 2026'),
          _buildDetailRow('Expiry', 'Never'),
          const SizedBox(height: 12),
          const Text(
            'Thank you for your support!',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildPackageSelection(WidgetRef ref, PremiumState state) {
    final packages = state.availablePackages;
    
    if (packages.isEmpty && PurchaseService.isMockMode) {
      return _PackageCard(
        title: 'Lifetime Plan (Demo)',
        price: '₹99',
        isSelected: true,
        onTap: () {},
      );
    }

    return Column(
      children: packages.map((package) {
        return _PackageCard(
          title: package.storeProduct.title,
          price: package.storeProduct.priceString,
          isSelected: state.selectedPackage?.identifier == package.identifier,
          onTap: () => ref.read(premiumProvider.notifier).selectPackage(package),
        );
      }).toList(),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildSubscribeButton(BuildContext context, WidgetRef ref, PremiumState state) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [Colors.orange, Color(0xFFFFCC33)]),
        boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final success = await ref.read(premiumProvider.notifier).purchase(null);
            if (success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Welcome to Pro!')),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'Subscribe Now',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
              ),
            ),
          ),
        ),
      ),
    ).animate(target: state.isLoading ? 0 : 1).fadeIn();
  }

  Widget _buildErrorState(WidgetRef ref, String message) {
    return Column(
      children: [
        const Icon(Icons.error_outline, color: Colors.redAccent, size: 32),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => ref.read(premiumProvider.notifier).fetchOffersAndCheckStatus(),
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Retry'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white10,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _PackageCard extends StatelessWidget {
  final String title;
  final String price;
  final bool isSelected;
  final VoidCallback onTap;

  const _PackageCard({
    required this.title,
    required this.price,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange.withOpacity(0.1) : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.orange : Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Iconsax.tick_circle5 : Iconsax.record,
                color: isSelected ? Colors.orange : Colors.white30,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                price,
                style: TextStyle(
                  color: isSelected ? Colors.orange : Colors.white54,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


