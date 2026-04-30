import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/l10n/app_localizations.dart';
import 'package:reducer/features/gallery/presentation/controllers/history_controller.dart';
import 'package:reducer/features/gallery/data/models/history_item.dart';
import 'package:reducer/common/widgets/app_loader.dart';
import 'package:reducer/common/widgets/app_empty_state.dart';
import 'package:reducer/common/widgets/app_error_widget.dart';
import 'package:reducer/common/widgets/app_dialog.dart';
import 'package:reducer/common/widgets/app_snackbar.dart';
import 'package:reducer/common/presentation/widgets/ads/banner_ad_widget.dart';
import 'package:reducer/features/gallery/presentation/widgets/history_card.dart';

/// Screen for displaying image processing history.
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
      setState(() => _appDocDir = dir.path);
    }
  }

  // ─────────────────────────────────────────────
  // SECTION: Actions
  // ─────────────────────────────────────────────

  Future<void> _removeItem(HistoryItem item, AppLocalizations l10n) async {
    await ref.read(historyControllerProvider.notifier).removeItem(item.id);
    if (!mounted) return;
    AppSnackbar.show(context, l10n.itemRemoved);
  }

  void _clearHistory(AppLocalizations l10n) {
    AppDialog.show(
      context,
      title: l10n.clearHistoryTitle,
      message: l10n.clearHistoryMessage,
      confirmLabel: l10n.clear,
      cancelLabel: l10n.cancel,
      type: AppDialogType.error,
      onConfirm: () => ref.read(historyControllerProvider.notifier).clearAll(),
    );
  }

  // ─────────────────────────────────────────────
  // SECTION: Build
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final historyAsync = ref.watch(historyControllerProvider);
    final items = historyAsync.valueOrNull?.items ?? const <HistoryItem>[];

    return Scaffold(
      body: Column(
        children: [
          const BannerAdWidget(),
          Expanded(
            child: historyAsync.when(
              loading: () => const AppLoader(message: 'Loading history...'),
              error: (error, stack) => AppErrorWidget(
                message: 'Error loading history: $error',
                onRetry: () => ref.read(historyControllerProvider.notifier).loadHistory(),
              ),
              data: (history) {
                if (history.items.isEmpty) {
                  return AppEmptyState(
                    title: l10n.galleryEmpty,
                    subtitle: l10n.galleryEmptyDescription,
                    icon: Iconsax.document_text,
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(AppDimensions.pagePadding.r),
                  itemCount: history.items.length,
                  itemBuilder: (context, index) {
                    final item = history.items[index];
                    return _HistoryItemWrapper(
                      item: item,
                      index: index,
                      appDocDir: _appDocDir,
                      onDismiss: () => _removeItem(item, l10n),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: items.isNotEmpty
          ? FloatingActionButton(
              mini: true,
              backgroundColor: AppColors.error,
              onPressed: () => _clearHistory(l10n),
              child: Icon(Iconsax.trash, color: Colors.white, size: AppDimensions.iconSm.r),
            )
          : null,
    );
  }
}

// ─────────────────────────────────────────────
// SECTION: Sub-widgets
// ─────────────────────────────────────────────

class _HistoryItemWrapper extends StatelessWidget {
  const _HistoryItemWrapper({
    required this.item,
    required this.index,
    required this.appDocDir,
    required this.onDismiss,
  });

  final HistoryItem item;
  final int index;
  final String? appDocDir;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(),
      onDismissed: (_) => onDismiss(),
      child: HistoryCard(item: item, appDocDir: appDocDir)
          .animate()
          .fadeIn(delay: Duration(milliseconds: 50 * index))
          .slideX(),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: AppDimensions.xl.w),
      margin: EdgeInsets.only(bottom: AppDimensions.md.h),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg.r),
      ),
      child: Icon(Iconsax.trash, color: Colors.white, size: AppDimensions.iconMd.r),
    );
  }
}

