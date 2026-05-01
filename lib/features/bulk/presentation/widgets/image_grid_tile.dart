import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ImageGridTile extends StatelessWidget {
  const ImageGridTile({
    super.key,
    required this.path,
    required this.isProcessed,
    required this.hasSucceeded,
  });

  final String path;
  final bool isProcessed;
  final bool hasSucceeded;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(path),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            // ── OPTIMIZATION: Limit decode resolution for grid thumbnails ──────
            cacheWidth: 200,
            cacheHeight: 200,
            gaplessPlayback: true,
          ),
        ),
        if (isProcessed)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: hasSucceeded
                    ? Colors.green.withValues(alpha: 0.3)
                    : Colors.red.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                hasSucceeded ? Iconsax.tick_circle : Iconsax.close_circle,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
      ],
    );
  }
}
