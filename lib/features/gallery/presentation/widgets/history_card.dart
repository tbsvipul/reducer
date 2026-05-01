import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/core/theme/app_theme.dart';
import 'package:reducer/features/gallery/data/models/history_item.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:reducer/core/services/permission_service.dart';
import 'package:reducer/l10n/app_localizations.dart';
import 'package:reducer/core/utils/file_utils.dart';
import 'package:reducer/common/widgets/app_snackbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HistoryCard extends StatelessWidget {
  final HistoryItem item;
  final String? appDocDir;

  const HistoryCard({super.key, required this.item, required this.appDocDir});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.md.h),
      decoration: AppTheme.cardDecoration(context),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg.r),
          onTap: () {
            if (item.isBulk) {
              context.push('/bulk-history-detail', extra: item);
            } else {
              _showActionSheet(context);
            }
          },
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.md.r),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm.r),
                  child: appDocDir == null
                      ? Container(
                          width: 72.r,
                          height: 72.r,
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2.r),
                          ),
                        )
                      : Builder(
                          builder: (context) {
                            final thumbPath = item.getAbsoluteThumbnailPath(
                              appDocDir!,
                            );
                            return Image.file(
                              File(thumbPath),
                              width: 72.r,
                              height: 72.r,
                              fit: BoxFit.cover,
                              cacheWidth: 144,
                              cacheHeight: 144,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 72.r,
                                  height: 72.r,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                  child: Icon(
                                    Iconsax.image,
                                    color: Colors.grey,
                                    size: 24.r,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
                SizedBox(width: AppDimensions.lg.w),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (item.isBulk) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryContainer,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusXs,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Iconsax.grid_5,
                                    size: 10.r,
                                    color: AppColors.secondaryDark,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.bulkCountLabel(item.itemCount),
                                    style: AppTextStyles.badgeLabel(
                                      context,
                                    ).copyWith(color: AppColors.secondaryDark),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: AppDimensions.sm.w),
                          ],
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusXs.r,
                              ),
                            ),
                            child: Text(
                              item.settings.format
                                  .toString()
                                  .split('.')
                                  .last
                                  .toUpperCase(),
                              style: AppTextStyles.badgeLabel(
                                context,
                              ).copyWith(color: AppColors.primaryDark),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            DateFormat('MMM dd').format(item.timestamp),
                            style: AppTextStyles.labelSmall(context),
                          ),
                        ],
                      ),
                      SizedBox(height: AppDimensions.sm.h),
                      Text(
                        '${FileUtils.formatBytes(item.originalSize)} → ${FileUtils.formatBytes(item.processedSize)}',
                        style: AppTextStyles.titleSmall(context),
                      ),
                      if (item.compressionPercent > 0) ...[
                        SizedBox(height: AppDimensions.xs.h),
                        Row(
                          children: [
                            Icon(
                              Iconsax.arrow_down,
                              size: 12.r,
                              color: AppColors.success,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${item.compressionPercent.toStringAsFixed(1)}% ${AppLocalizations.of(context)!.smaller}',
                              style: AppTextStyles.labelSmall(
                                context,
                              ).copyWith(color: AppColors.success),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: AppDimensions.sm.w),
                Icon(Iconsax.arrow_right_3, size: 16.r, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showActionSheet(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(AppDimensions.lg.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Text(l10n.imageActions, style: AppTextStyles.titleMedium(context)),
            SizedBox(height: 24.h),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(AppDimensions.sm.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.save_2,
                  color: AppColors.primary,
                  size: 24.r,
                ),
              ),
              title: Text(l10n.saveToGallery),
              onTap: () async {
                Navigator.pop(context);
                final path = item
                    .getAbsoluteProcessedPaths(appDocDir ?? '')
                    .firstOrNull;
                if (path != null && await File(path).exists()) {
                  if (!context.mounted) return;
                  final ok = await PermissionService.instance
                      .ensurePhotosPermission(context);
                  if (!context.mounted) return;
                  if (ok) {
                    await Gal.putImage(path, album: 'Reducer');
                    _showSnackBar(
                      messenger,
                      l10n.savedToGallerySuccess,
                      AppSnackbarType.success,
                    );
                  }
                } else {
                  _showSnackBar(
                    messenger,
                    l10n.processedFileNotFound,
                    AppSnackbarType.error,
                  );
                }
              },
            ),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(AppDimensions.sm.r),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.share,
                  color: AppColors.secondary,
                  size: 24.r,
                ),
              ),
              title: Text(l10n.shareImage),
              onTap: () async {
                Navigator.pop(context);
                final path = item
                    .getAbsoluteProcessedPaths(appDocDir ?? '')
                    .firstOrNull;
                if (path != null && await File(path).exists()) {
                  if (!context.mounted) return;
                  await SharePlus.instance.share(
                    ShareParams(files: [XFile(path)]),
                  );
                } else {
                  _showSnackBar(
                    messenger,
                    l10n.processedFileNotFound,
                    AppSnackbarType.error,
                  );
                }
              },
            ),
            SizedBox(height: AppDimensions.md.h),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(
    ScaffoldMessengerState messenger,
    String message,
    AppSnackbarType type,
  ) {
    messenger
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: switch (type) {
            AppSnackbarType.success => AppColors.success,
            AppSnackbarType.error => AppColors.error,
            AppSnackbarType.warning => AppColors.warning,
            AppSnackbarType.info => AppColors.primary,
          },
        ),
      );
  }
}
