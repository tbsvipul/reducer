import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/core/services/review_service.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? AppColors.darkSurfaceGradient
              : AppColors.lightSurfaceGradient,
        ),
        boxShadow: isDark
            ? AppColors.cardShadowDark
            : AppColors.cardShadowLight,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl2),
        child: Stack(
          children: [
            // Subtle background decoration
            Positioned(
              right: -AppDimensions.xl,
              top: -AppDimensions.xl,
              child: Icon(
                Iconsax.heart,
                size: AppDimensions.iconXl4 * 1.5,
                color: AppColors.premium.withValues(alpha: 0.05),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppDimensions.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                        padding: const EdgeInsets.all(AppDimensions.md),
                        decoration: BoxDecoration(
                          color: AppColors.premium.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Iconsax.star5,
                          color: AppColors.premium,
                          size: AppDimensions.iconXl,
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat())
                      .shimmer(
                        delay: 2000.ms,
                        duration: 1500.ms,
                        color: isDark
                            ? Colors.white24
                            : AppColors.primary.withValues(alpha: 0.2),
                      ),

                  const SizedBox(height: AppDimensions.lg),

                  Text(
                    'Enjoying Reducer?',
                    style: AppTextStyles.titleMedium(
                      context,
                    ).copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppDimensions.xs),

                  Text(
                    'Your feedback helps us grow and improve.',
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: isDark
                          ? AppColors.onDarkSurfaceVariant
                          : AppColors.onLightSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppDimensions.xl),

                  // Star Rating Mockup
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return const Icon(
                        Iconsax.star5,
                        color: AppColors.premium,
                        size: AppDimensions.iconLg,
                      ).animate().scale(
                        delay: (index * 100).ms,
                        duration: 400.ms,
                        curve: Curves.easeOutBack,
                      );
                    }),
                  ),

                  const SizedBox(height: AppDimensions.xl),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => ReviewService().openStoreListing(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.premium,
                        foregroundColor: AppColors.onPremium,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.lg,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusLg,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Rate on Play Store',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.95, 0.95));
  }
}
