import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../../core/design_tokens.dart';
import '../../providers/history_provider.dart';
import '../../models/image_settings.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../widgets/banner_ad_widget.dart';
import '../../models/ad_state.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  String? _appDocDir;

  @override
  void initState() {
    super.initState();
    _initAppDir();
    // Load history when screen opens
    Future.microtask(() => ref.read(historyProvider).loadHistory());
  }

  Future<void> _initAppDir() async {
    final dir = await getApplicationDocumentsDirectory();
    if (mounted) {
      setState(() {
        _appDocDir = dir.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider);
    final items = history.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit History'),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Iconsax.trash),
              onPressed: () => _showClearDialog(context),
            ),
        ],
      ),
      body: Column(
        children: [
          const BannerAdWidget(),
          Expanded(
            child: items.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Dismissible(
                        key: Key(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Iconsax.trash, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          ref.read(historyProvider).removeItem(item.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Item removed from history')),
                          );
                        },
                        child: _buildHistoryCard(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.clock, size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          const Text(
            'No past edits found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Process and export images to see them here',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Start New Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (item.isBulk) {
            context.push('/bulk-history-detail', extra: item);
          } else {
            // TODO: Implement re-edit functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Re-edit feature coming soon!')),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _appDocDir == null
                    ? Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Builder(builder: (context) {
                        final thumbPath = item.getAbsoluteThumbnailPath(_appDocDir!);
                        final file = File(thumbPath);
                        return file.existsSync()
                            ? Image.file(
                                file,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child: const Icon(Iconsax.image, color: Colors.grey),
                              );
                      }),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (item.isBulk) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Iconsax.grid_5, size: 12, color: Colors.orange),
                                const SizedBox(width: 4),
                                Text(
                                  'BULK (${item.itemCount})',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: DesignTokens.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.settings.format.toString().split('.').last.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: DesignTokens.primaryBlue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MMM dd, HH:mm').format(item.timestamp),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_formatSize(item.originalSize)} → ${_formatSize(item.processedSize)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    if (item.compressionPercent > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Iconsax.arrow_down, size: 14, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            '${item.compressionPercent.toStringAsFixed(1)}% smaller',
                            style: const TextStyle(fontSize: 12, color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Iconsax.arrow_right_3, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History?'),
        content: const Text('This will remove all past edits from history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(historyProvider).clearAll();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
