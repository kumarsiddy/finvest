import 'package:finvest/presentation/shared/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

class AppImage extends StatelessWidget {
  final String imageKey;
  final double? height;
  final double? width;
  final Color? color;
  final Widget? placeholder;
  final BoxFit? fit;

  const AppImage(
    this.imageKey, {
    Key? key,
    this.height,
    this.width,
    this.color,
    this.placeholder,
    this.fit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Uri.tryParse(imageKey)?.hasAbsolutePath ?? false) {
      if (imageKey.endsWith('.svg')) {
        return SvgPicture.network(
          imageKey,
          placeholderBuilder: (_) =>
              placeholder ??
              _ShimmerPlaceHolder(
                height: height,
                width: width,
              ),
          height: height,
          width: width,
          color: color,
          fit: fit ?? BoxFit.fitWidth,
        );
      }

      return CachedNetworkImage(
        imageUrl: imageKey,
        placeholder: (context, url) =>
            placeholder ??
            _ShimmerPlaceHolder(
              height: height,
              width: width,
            ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
        height: height,
        width: width,
        color: color,
        fit: fit ?? BoxFit.fitWidth,
      );
    }

    if (imageKey.endsWith('.svg')) {
      return SvgPicture.asset(
        imageKey,
        height: height,
        width: width,
        color: color,
        fit: fit ?? BoxFit.fitWidth,
      );
    }

    return Image.asset(
      imageKey,
      height: height,
      width: width,
      errorBuilder: (context, error, _) => const SizedBox(),
      color: color,
      fit: fit ?? BoxFit.fitWidth,
    );
  }
}

class _ShimmerPlaceHolder extends StatelessWidget {
  final double? height;
  final double? width;

  const _ShimmerPlaceHolder({
    Key? key,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.white,
      highlightColor: AppColors.greyLight,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: AppColors.white,
        ),
      ),
    );
  }
}
