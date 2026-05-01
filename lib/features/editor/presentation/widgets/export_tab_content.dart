import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reducer/common/presentation/widgets/ads/native_ad_widget.dart';
import 'package:reducer/common/widgets/app_button.dart';
import 'package:reducer/core/models/image_settings.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/core/theme/app_theme.dart';
import 'package:reducer/core/utils/target_dimension_calculator.dart';
import 'package:reducer/l10n/app_localizations.dart';

class ExportTabContent extends StatefulWidget {
  final Uint8List? processedImageBytes;
  final Uint8List? originalThumbnail;
  final Uint8List? previewThumbnail;
  final ImageSettings settings;
  final int originalSize;
  final int originalWidth;
  final int originalHeight;
  final VoidCallback onSave;
  final VoidCallback onShare;

  const ExportTabContent({
    super.key,
    required this.processedImageBytes,
    required this.originalThumbnail,
    required this.previewThumbnail,
    required this.settings,
    required this.originalSize,
    required this.originalWidth,
    required this.originalHeight,
    required this.onSave,
    required this.onShare,
  });

  @override
  State<ExportTabContent> createState() => _ExportTabContentState();
}

class _ExportTabContentState extends State<ExportTabContent> {
  bool _showBeforeImage = false;

  TargetDimensions get _selectedDimensions => TargetDimensions.fromScale(
    originalWidth: widget.originalWidth,
    originalHeight: widget.originalHeight,
    scalePercent: widget.settings.scalePercent,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final previewHeight = clampDouble(
      MediaQuery.sizeOf(context).height * 0.34,
      240,
      420,
    );

    if (widget.processedImageBytes == null) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.info_circle,
                size: AppDimensions.iconXl4,
                color: isDark
                    ? AppColors.onDarkSurfaceVariant
                    : AppColors.onLightSurfaceVariant,
              ),
              const SizedBox(height: AppDimensions.lg),
              Text(
                l10n.processedImages,
                style: AppTextStyles.titleMedium(context).copyWith(
                  color: isDark
                      ? AppColors.onDarkSurfaceVariant
                      : AppColors.onLightSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppDimensions.xs),
              Text(
                l10n.applyChangesMessage,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall(context).copyWith(
                  color: isDark
                      ? AppColors.onDarkSurfaceVariant
                      : AppColors.onLightSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppDimensions.xl2),
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.pagePadding,
                ),
                child: NativeAdWidget(size: NativeAdSize.medium),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.pagePadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: AppTheme.cardDecoration(context),
            child: Column(
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: AppDimensions.sm,
                  spacing: AppDimensions.sm,
                  children: [
                    Text(
                      _showBeforeImage ? l10n.showBefore : l10n.showAfter,
                      style: AppTextStyles.titleMedium(
                        context,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () =>
                          setState(() => _showBeforeImage = !_showBeforeImage),
                      icon: Icon(
                        _showBeforeImage ? Iconsax.eye : Iconsax.eye_slash,
                        size: AppDimensions.iconSm,
                      ),
                      label: Text(
                        _showBeforeImage ? l10n.showAfter : l10n.showBefore,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.md),
                Semantics(
                  label: l10n.processedImages,
                  hint: l10n.showBefore,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      GestureDetector(
                        onPanStart: (_) =>
                            setState(() => _showBeforeImage = true),
                        onPanEnd: (_) =>
                            setState(() => _showBeforeImage = false),
                        onLongPressStart: (_) =>
                            setState(() => _showBeforeImage = true),
                        onLongPressEnd: (_) =>
                            setState(() => _showBeforeImage = false),
                        child: RepaintBoundary(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMd,
                            ),
                            child: Image.memory(
                              _showBeforeImage
                                  ? (widget.originalThumbnail ??
                                        widget.previewThumbnail ??
                                        widget.processedImageBytes!)
                                  : (widget.previewThumbnail ??
                                        widget.processedImageBytes!),
                              height: previewHeight,
                              width: double.infinity,
                              fit: BoxFit.contain,
                              cacheWidth: 800,
                              cacheHeight: 600,
                              gaplessPlayback: true,
                            ),
                          ),
                        ),
                      ),
                      if (!_showBeforeImage)
                        Positioned(
                          bottom: AppDimensions.md,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.md,
                              vertical: AppDimensions.xs,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.54),
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusXl,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Iconsax.finger_scan,
                                  color: Colors.white,
                                  size: AppDimensions.iconSm,
                                ),
                                const SizedBox(width: AppDimensions.sm),
                                Text(
                                  l10n.showBefore,
                                  style: AppTextStyles.labelSmall(
                                    context,
                                  ).copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
                Text(
                  l10n.readyToExport,
                  style: AppTextStyles.headlineSmall(
                    context,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppDimensions.md),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.lg),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Column(
                    children: [
                      _exportInfoRow(
                        context,
                        l10n.formatLabel,
                        widget.settings.format.name,
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      _exportInfoRow(
                        context,
                        l10n.imageQuality,
                        '${widget.settings.quality.toInt()}%',
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      _exportInfoRow(
                        context,
                        l10n.dimensions,
                        '${_selectedDimensions.width} x ${_selectedDimensions.height}',
                        valueColor: AppColors.primary,
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      _exportInfoRow(
                        context,
                        l10n.targetFileSize,
                        _formatFileSize(widget.processedImageBytes!.length),
                        valueColor:
                            widget.processedImageBytes!.length <
                                widget.originalSize
                            ? AppColors.success
                            : AppColors.primary,
                      ),
                      if (widget.processedImageBytes!.length <
                          widget.originalSize) ...[
                        const SizedBox(height: AppDimensions.sm),
                        _exportInfoRow(
                          context,
                          l10n.spaceSaved,
                          '${((widget.originalSize - widget.processedImageBytes!.length) / widget.originalSize * 100).toStringAsFixed(1)}%',
                          valueColor: AppColors.success,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.xl),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: l10n.saveToGallery,
                  icon: Iconsax.save_2,
                  semanticLabel: l10n.saveToGallery,
                  onPressed: widget.onSave,
                  isFullWidth: true,
                ),
              ),
              const SizedBox(width: AppDimensions.lg),
              Expanded(
                child: AppButton(
                  label: l10n.share,
                  icon: Iconsax.share,
                  semanticLabel: l10n.share,
                  onPressed: widget.onShare,
                  isFullWidth: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _exportInfoRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: isDark
                  ? AppColors.onDarkSurfaceVariant
                  : AppColors.onLightSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.md),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.bodyMedium(
              context,
            ).copyWith(fontWeight: FontWeight.bold, color: valueColor),
          ),
        ),
      ],
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(2)} MB (${kb.toStringAsFixed(0)} KB)';
  }
}
