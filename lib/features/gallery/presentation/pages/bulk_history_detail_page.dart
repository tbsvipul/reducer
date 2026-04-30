import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reducer/features/gallery/data/models/history_item.dart';
import 'package:reducer/core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:reducer/core/services/permission_service.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/common/presentation/widgets/ads/banner_ad_widget.dart';
import 'package:reducer/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reducer/common/widgets/app_snackbar.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';

class BulkHistoryDetailScreen extends StatefulWidget {
  final HistoryItem item;

  const BulkHistoryDetailScreen({super.key, required this.item});

  @override
  State<BulkHistoryDetailScreen> createState() => _BulkHistoryDetailScreenState();
}

class _BulkHistoryDetailScreenState extends State<BulkHistoryDetailScreen> {
  String? _appDocDir;
  List<String> _resolvedPaths = [];
  Map<String, int> _fileSizes = {};

  @override
  void initState() {
    super.initState();
    _initAppDir();
  }

  Future<void> _initAppDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final paths = widget.item.getAbsoluteProcessedPaths(dir.path);
    
    // Pre-calculate file sizes to avoid FutureBuilder in ListView
    final sizes = <String, int>{};
    for (final path in paths) {
      try {
        final file = File(path);
        if (await file.exists()) {
          sizes[path] = await file.length();
        }
      } catch (e) {
        debugPrint('Error getting size for $path: $e');
      }
    }

    if (mounted) {
      setState(() {
        _appDocDir = dir.path;
        _resolvedPaths = paths;
        _fileSizes = sizes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(l10n.bulkSessionDetails),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const BannerAdWidget(),
          // Header summary card
          Container(
            padding: EdgeInsets.all(AppDimensions.lg.r),
            margin: EdgeInsets.all(AppDimensions.md.r),
            decoration: AppTheme.cardDecoration(context),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppDimensions.md.r),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Iconsax.grid_5, color: AppColors.warning, size: 24.r),
                    ),
                    SizedBox(width: AppDimensions.md.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.xImagesProcessed(widget.item.itemCount),
                            style: AppTextStyles.titleMedium(context).copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            DateFormat('MMMM dd, yyyy • HH:mm').format(widget.item.timestamp),
                            style: AppTextStyles.labelSmall(context).copyWith(
                              color: isDark ? AppColors.onDarkSurfaceVariant : AppColors.onLightSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: AppDimensions.xl2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(l10n.format, widget.item.settings.format.name.toUpperCase()),
                    _buildStat(l10n.imageQuality, '${widget.item.settings.quality}%'),
                    _buildStat('Total Sav.', '${widget.item.compressionPercent.toStringAsFixed(1)}%'),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.lg.w, vertical: AppDimensions.sm.h),
            child: Row(
              children: [
                Text(
                  'Processed Images',
                  style: AppTextStyles.titleSmall(context).copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // List of images
          Expanded(
            child: _resolvedPaths.isEmpty && (_appDocDir != null || widget.item.processedPaths.isEmpty)
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.image, size: 48.r, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        SizedBox(height: AppDimensions.md.h),
                        Text(
                          _appDocDir == null 
                              ? l10n.loadingImages 
                              : l10n.noImagesFoundInSession,
                          style: AppTextStyles.labelMedium(context).copyWith(
                            color: isDark ? AppColors.onDarkSurfaceVariant : AppColors.onLightSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: AppDimensions.md.w),
                    itemCount: _resolvedPaths.length,
                    itemBuilder: (context, index) {
                      final path = _resolvedPaths[index];
                      final file = File(path);
                      final fileName = p.basename(path);

                      return Card(
                        margin: EdgeInsets.only(bottom: AppDimensions.md.h),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
                          side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(AppDimensions.sm.r),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSm.r),
                            child: file.existsSync()
                                ? Image.file(
                                    file,
                                    width: 60.r,
                                    height: 60.r,
                                    fit: BoxFit.cover,
                                    cacheWidth: 120, // 2x for retina
                                    cacheHeight: 120,
                                  )
                                : Container(
                                    width: 60.r,
                                    height: 60.r,
                                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                                    child: Icon(Iconsax.image, size: 24.r),
                                  ),
                          ),
                          title: Text(
                            fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelMedium(context).copyWith(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            _fileSizes.containsKey(path)
                                ? _formatSize(_fileSizes[path]!)
                                : '...',
                            style: AppTextStyles.labelSmall(context),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Iconsax.share, size: 20.r, color: AppColors.secondary),
                                onPressed: () async {
                                  if (file.existsSync()) {
                                    await SharePlus.instance.share(
                                      ShareParams(files: [XFile(path)]),
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(Iconsax.save_2, size: 20.r, color: AppColors.primary),
                                onPressed: () async {
                                  if (file.existsSync()) {
                                    final ok = await PermissionService.instance.ensurePhotosPermission(context);
                                    if (ok && mounted) {
                                      await Gal.putImage(path, album: 'Reducer');
                                      if (context.mounted) {
                                        AppSnackbar.show(
                                          context,
                                          'Saved to gallery!',
                                          type: AppSnackbarType.success,
                                        );
                                      }
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.labelSmall(context).copyWith(color: Colors.grey)),
        SizedBox(height: 4.h),
        Text(value, style: AppTextStyles.titleSmall(context).copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}


