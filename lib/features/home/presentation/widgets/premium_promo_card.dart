import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/l10n/app_localizations.dart';

class PremiumPromoCard extends StatelessWidget {
  const PremiumPromoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1), // Indigo
            Color(0xFFA855F7), // Purple
            Color(0xFFEC4899), // Pink
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA855F7).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorative circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.sm),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.crown_15,
                      color: Colors.white,
                      size: 20,
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(delay: 2.seconds, duration: 1500.ms)
                  .shake(hz: 4, curve: Curves.easeInOutCubic),
                  
                  const SizedBox(width: AppDimensions.md),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.sm,
                      vertical: AppDimensions.xs2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: Text(
                      l10n.premium.toUpperCase(),
                      style: AppTextStyles.labelSmall(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
          
              const SizedBox(height: AppDimensions.lg),
              
              Text(
                l10n.unlockAllProFeatures,
                style: AppTextStyles.headlineSmall(context).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              
              const SizedBox(height: AppDimensions.xs),
              
              Text(
                l10n.promoSubtitle,
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              
              const SizedBox(height: AppDimensions.xl),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedBtn(
                  onPressed: () => context.push('/premium'),
                  text: l10n.upgradeNow,
                ),
              ),
            ],
          ),
        ],
      ),
    )
    .animate()
    .fadeIn(duration: 600.ms)
    .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), curve: Curves.easeOutBack)
    .slideY(begin: 0.1, end: 0);
  }
}

class ElevatedBtn extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const ElevatedBtn({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFA855F7),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

