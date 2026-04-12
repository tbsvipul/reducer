import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_spacing.dart';
import 'package:reducer/features/gallery/presentation/controllers/history_controller.dart';
import 'package:reducer/features/gallery/data/models/history_item.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reducer/shared/presentation/widgets/ads/banner_ad_widget.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:reducer/features/gallery/presentation/widgets/history_card.dart';
import 'package:reducer/features/gallery/presentation/widgets/gallery_empty_state.dart';
import 'package:reducer/features/gallery/presentation/widgets/gallery_error_state.dart';
import 'package:reducer/features/gallery/presentation/widgets/clear_history_dialog.dart';


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
    final historyAsync = ref.watch(historyControllerProvider);
    final items = historyAsync.valueOrNull?.items ?? const <HistoryItem>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit History'),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Iconsax.trash),
              onPressed: () => showDialog(
                context: context,
                builder: (context) => ClearHistoryDialog(
                  onClear: () async {
                    final notifier = await ref.readHistoryControllerReady();
                    await notifier.clearAll();
                  },
                ),
              ),

            ),
        ],
      ),
      body: Column(
        children: [
          // Fix: Delay banner platform view until history is ready.
          if (historyAsync.hasValue) const BannerAdWidget(),
          Expanded(
            child: historyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => GalleryErrorState(
                error: error,
                onRetry: () async {
                  final notifier = await ref.readHistoryControllerReady();
                  await notifier.loadHistory();
                },
              ),
              data: (history) {
                if (history.items.isEmpty) return const GalleryEmptyState();

                return ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: history.items.length,
                  itemBuilder: (context, index) {
                    final item = history.items[index];
                    return Dismissible(
                      key: Key(item.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: AppSpacing.xl),
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusLg),
                        ),
                        child:
                            const Icon(Iconsax.trash, color: Colors.white),
                      ),
                      onDismissed: (_) async {
                        final notifier =
                            await ref.readHistoryControllerReady();
                        await notifier.removeItem(item.id);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Item removed from history'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.darkSurface,
                          ),
                        );
                      },
                      child: HistoryCard(item: item, appDocDir: _appDocDir)

                          .animate()
                          .fadeIn(
                            delay: Duration(milliseconds: 50 * index),
                          )
                          .slideX(),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}

