import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:reducer/core/theme/app_spacing.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/shared/widgets/app_button.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reducer/features/auth/presentation/providers/auth_providers.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reducer/l10n/app_localizations.dart';

class AlreadyProState extends ConsumerWidget {
  const AlreadyProState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      body: Stack(
        children: [
          // Premium Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF020617),
                    Color(0xFF0F172A),
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: userAsync.when(
              data: (user) {
                final dateFormat = DateFormat('MMM dd, yyyy');
                final status = user?.subscriptionStatus ?? 'free';
                final billingPeriod = user?.billingPeriod ?? 'Pro';
                final l10n = AppLocalizations.of(context)!;
                
                String type;
                if (billingPeriod.toLowerCase() == 'yearly') {
                  type = l10n.yearly;
                } else if (billingPeriod.toLowerCase() == 'monthly') {
                  type = l10n.monthly;
                } else {
                  type = billingPeriod;
                }
                final expiry = user?.expiryDate != null ? dateFormat.format(user!.expiryDate!) : l10n.lifetime;
                final start = user?.subscriptionStartDate != null ? dateFormat.format(user!.subscriptionStartDate!) : 'N/A';

                return Column(
                  children: [
                    AppBar(
                      title: Text(l10n.premiumMembership, style: TextStyle(fontSize: 14.sp, letterSpacing: 2, fontWeight: FontWeight.bold)),
                      centerTitle: true,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      leading: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl3, vertical: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 20.h),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFFACC15).withValues(alpha: 0.1),
                                border: Border.all(color: const Color(0xFFFACC15).withValues(alpha: 0.2)),
                              ),
                              child: Icon(
                                Icons.verified,
                                size: 60.r,
                                color: const Color(0xFFFACC15),
                              ),
                            ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
                            const SizedBox(height: AppSpacing.xl2),
                            Text(
                              l10n.eliteMember,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ).animate().fadeIn(delay: 200.ms),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              l10n.fullAccessActive,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium(context).copyWith(
                                color: Colors.white60,
                                height: 1.6,
                              ),
                            ).animate().fadeIn(delay: 400.ms),
                            
                            const SizedBox(height: AppSpacing.xl4),
                            // Plan Info Card
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.xl2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusXl2),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              child: Column(
                                children: [
                                  _buildInfoRow(l10n.currentPlan, type.toUpperCase(), isGold: true),
                                  const  Divider(height: AppSpacing.xl3, color: Colors.white10),
                                  _buildInfoRow(l10n.statusLabel, status.toUpperCase()),
                                  const Divider(height: AppSpacing.xl3, color: Colors.white10),
                                  _buildInfoRow(l10n.startDate, start),
                                  const Divider(height: AppSpacing.xl3, color: Colors.white10),
                                  _buildInfoRow(l10n.nextBilling, expiry),
                                ],
                              ),
                            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),

                            const SizedBox(height: AppSpacing.xl5),
                            AppButton(
                              label: l10n.manageSubscription,
                              icon: Icons.settings,
                              style: AppButtonStyle.outline,
                              onPressed: () => _openSubscriptionManagement(),
                            ).animate().fadeIn(delay: 800.ms),
                            const SizedBox(height: AppSpacing.xl),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isGold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white54, fontSize: 13.sp, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(
            color: isGold ? const Color(0xFFFACC15) : Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Future<void> _openSubscriptionManagement() async {
    final uri = Uri.parse('https://play.google.com/store/account/subscriptions');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

