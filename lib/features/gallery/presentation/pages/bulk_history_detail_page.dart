import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reducer/features/gallery/data/models/history_item.dart';
import 'package:reducer/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class BulkHistoryDetailScreen extends StatefulWidget {
  final HistoryItem item;

  const BulkHistoryDetailScreen({super.key, required this.item});

  @override
  State<BulkHistoryDetailScreen> createState() => _BulkHistoryDetailScreenState();
}

class _BulkHistoryDetailScreenState extends State<BulkHistoryDetailScreen> {
  String? _appDocDir;
  List<String> _resolvedPaths = [];

  @override
  void initState() {
    super.initState();
    _initAppDir();
  }

  Future<void> _initAppDir() async {
    final dir = await getApplicationDocumentsDirectory();
    if (mounted) {
      setState(() {
        _appDocDir = dir.path;
        _resolvedPaths = widget.item.getAbsoluteProcessedPaths(dir.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Session Details'),
      ),
      body: Column(
        children: [
          // Header summary card
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration(context),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Iconsax.grid_5, color: Colors.orange),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.item.itemCount} Images Processed',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            DateFormat('MMMM dd, yyyy • HH:mm').format(widget.item.timestamp),
                            style: const TextStyle(color: Colors.grey),
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
                    _buildStat('Format', widget.item.settings.format.name.toUpperCase()),
                    _buildStat('Quality', '${widget.item.settings.quality}%'),
                    _buildStat('Total Sav.', '${widget.item.compressionPercent.toStringAsFixed(1)}%'),
                  ],
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Processed Images',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                        Icon(Iconsax.image, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          _appDocDir == null ? 'Loading images...' : 'No images found in this session',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _resolvedPaths.length,
                    itemBuilder: (context, index) {
                      final path = _resolvedPaths[index];
                      final file = File(path);
                      final fileName = p.basename(path);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: file.existsSync()
                                ? Image.file(
                                    file,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[200],
                                    child: const Icon(Iconsax.image),
                                  ),
                          ),
                          title: Text(
                            fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          subtitle: FutureBuilder<int>(
                            future: file.existsSync() ? file.length() : Future.value(0),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Text(_formatSize(snapshot.data!));
                              }
                              return const Text('...');
                            },
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
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

