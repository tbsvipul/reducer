import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_dimensions.dart';

import '../../../../core/theme/app_text_styles.dart';

class FeatureListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isPro;
  final bool hasAccess;
  final VoidCallback onTap;

  const FeatureListTile({
    super.key,
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
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.lg,
              vertical: AppDimensions.md,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  decoration: BoxDecoration(
                    color: isPro && !hasAccess
                        ? (isDark
                              ? Colors.white10
                              : AppColors.lightSurfaceVariant)
                        : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Icon(
                    icon,
                    color: isPro && !hasAccess
                        ? (isDark
                              ? AppColors.onDarkSurfaceVariant
                              : AppColors.onLightSurfaceVariant)
                        : AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppDimensions.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.titleMedium(context).copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.onDarkSurface
                                  : AppColors.onLightSurface,
                            ),
                          ),
                          if (isPro && !hasAccess) ...[
                            const SizedBox(width: AppDimensions.sm),
                            Icon(
                              Iconsax.lock,
                              size: 14,
                              color: isDark
                                  ? AppColors.onDarkSurfaceVariant
                                  : AppColors.onLightSurfaceVariant,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall(context).copyWith(
                          color: isDark
                              ? AppColors.onDarkSurfaceVariant
                              : AppColors.onLightSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Iconsax.arrow_right_3,
                  size: 16,
                  color: isDark ? Colors.white12 : AppColors.lightBorder,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
