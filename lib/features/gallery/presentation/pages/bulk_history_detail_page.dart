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
import 'package:reducer/shared/presentation/widgets/ads/banner_ad_widget.dart';
import 'package:reducer/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.bulkSessionDetails),
      ),
      body: Column(
        children: [
          const BannerAdWidget(),
          // Header summary card
          Container(
            padding: EdgeInsets.all(20.r),
            margin: EdgeInsets.all(16.r),
            decoration: AppTheme.cardDecoration(context),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Iconsax.grid_5, color: Colors.orange, size: 24.r),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.xImagesProcessed(widget.item.itemCount),
                            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            DateFormat('MMMM dd, yyyy • HH:mm').format(widget.item.timestamp),
                            style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(AppLocalizations.of(context)!.format, widget.item.settings.format.name.toUpperCase()),
                    _buildStat(AppLocalizations.of(context)!.imageQuality, '${widget.item.settings.quality}%'),
                    _buildStat('Total Sav.', '${widget.item.compressionPercent.toStringAsFixed(1)}%'),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: Row(
              children: [
                Text(
                  'Processed Images',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
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
                        Icon(Iconsax.image, size: 48.r, color: Colors.grey[300]),
                        SizedBox(height: 16.h),
                        Text(
                          _appDocDir == null 
                              ? AppLocalizations.of(context)!.loadingImages 
                              : AppLocalizations.of(context)!.noImagesFoundInSession,
                          style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: _resolvedPaths.length,
                    itemBuilder: (context, index) {
                      final path = _resolvedPaths[index];
                      final file = File(path);
                      final fileName = p.basename(path);

                      return Card(
                        margin: EdgeInsets.only(bottom: 12.h),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(8.r),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
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
                                    color: Colors.grey[200],
                                    child: Icon(Iconsax.image, size: 24.r),
                                  ),
                          ),
                          title: Text(
                            fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            _fileSizes.containsKey(path)
                                ? _formatSize(_fileSizes[path]!)
                                : '...',
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
                                  final messenger = ScaffoldMessenger.of(context);
                                  if (file.existsSync()) {
                                    final ok = await PermissionService.instance.ensurePhotosPermission(context);
                                    if (ok) {
                                      await Gal.putImage(path, album: 'Reducer');
                                      if (context.mounted) {
                                        messenger.showSnackBar(
                                          const SnackBar(content: Text('Saved to gallery!'), behavior: SnackBarBehavior.floating),
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
        Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
        SizedBox(height: 4.h),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
      ],
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}


