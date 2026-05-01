import 'package:flutter/material.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_spacing.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reducer/l10n/app_localizations.dart';

class GalleryErrorState extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const GalleryErrorState({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.warning_2, color: AppColors.error, size: 36),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppLocalizations.of(context)!.historyLoadError,
              style: AppTextStyles.titleMedium(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '$error',
              style: AppTextStyles.bodySmall(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: onRetry,
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      ),
    );
  }
}
