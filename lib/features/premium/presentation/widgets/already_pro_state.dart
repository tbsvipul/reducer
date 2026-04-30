import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/common/widgets/app_button.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reducer/features/auth/presentation/controllers/auth_controller.dart';
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
                        padding: EdgeInsets.symmetric(horizontal: AppDimensions.xl3.w, vertical: 20.h),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 20.h),
                            Container(
                              padding: EdgeInsets.all(20.r),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFFACC15).withValues(alpha: 0.1),
                                border: Border.all(color: const Color(0xFFFACC15).withValues(alpha: 0.2), width: 1.r),
                              ),
                              child: Icon(
                                Icons.verified,
                                size: 60.r,
                                color: const Color(0xFFFACC15),
                              ),
                            ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
                            SizedBox(height: AppDimensions.xl2.h),
                            Text(
                              l10n.eliteMember,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ).animate().fadeIn(delay: 200.ms),
                            SizedBox(height: AppDimensions.md.h),
                            Text(
                              l10n.fullAccessActive,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium(context).copyWith(
                                color: Colors.white60,
                                height: 1.6,
                              ),
                            ).animate().fadeIn(delay: 400.ms),
                            
                            SizedBox(height: AppDimensions.xl4.h),
                            // Plan Info Card
                            Container(
                              padding: EdgeInsets.all(AppDimensions.xl2.r),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusXl2.r),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.r),
                              ),
                              child: Column(
                                children: [
                                  _buildInfoRow(l10n.currentPlan, type.toUpperCase(), isGold: true),
                                  Divider(height: AppDimensions.xl3.h, color: Colors.white10, thickness: 1.r),
                                  _buildInfoRow(l10n.statusLabel, status.toUpperCase()),
                                  Divider(height: AppDimensions.xl3.h, color: Colors.white10, thickness: 1.r),
                                  _buildInfoRow(l10n.startDate, start),
                                  Divider(height: AppDimensions.xl3.h, color: Colors.white10, thickness: 1.r),
                                  _buildInfoRow(l10n.nextBilling, expiry),
                                ],
                              ),
                            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),

                            SizedBox(height: AppDimensions.xl5.h),
                            AppButton(
                              label: l10n.manageSubscription,
                              icon: Icons.settings,
                              style: AppButtonStyle.outline,
                              onPressed: () => _openSubscriptionManagement(),
                            ).animate().fadeIn(delay: 800.ms),
                            SizedBox(height: AppDimensions.xl.h),
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

