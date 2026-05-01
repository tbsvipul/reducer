import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reducer/common/widgets/app_loader.dart';

class AppImage extends StatelessWidget {
  final String? url;
  final String? assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppImage({
    super.key,
    this.url,
    this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    Widget image;

    if (assetPath != null) {
      if (assetPath!.endsWith('.svg')) {
        image = SvgPicture.asset(
          assetPath!,
          width: width?.w,
          height: height?.h,
          fit: fit,
        );
      } else {
        image = Image.asset(
          assetPath!,
          width: width?.w,
          height: height?.h,
          fit: fit,
        );
      }
    } else if (url != null && url!.isNotEmpty) {
      image = CachedNetworkImage(
        imageUrl: url!,
        width: width?.w,
        height: height?.h,
        fit: fit,
        placeholder: (context, url) =>
            placeholder ?? const Center(child: AppLoader(size: 20)),
        errorWidget: (context, url, error) =>
            errorWidget ?? const Icon(Icons.broken_image, color: Colors.grey),
      );
    } else {
      image =
          errorWidget ??
          const Icon(Icons.image_not_supported, color: Colors.grey);
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius!.r),
        child: image,
      );
    }

    return image;
  }
}
