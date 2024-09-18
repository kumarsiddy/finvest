import 'package:finvest/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

abstract class BaseImage extends StatelessWidget {
  final String imageKey;
  final double height;
  final double width;

  const BaseImage({
    Key? key,
    required this.imageKey,
    required this.height,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Uri.tryParse(imageKey)?.hasAbsolutePath ?? false) {
      if (imageKey.endsWith('.svg')) {
        return SvgPicture.network(
          imageKey,
          height: height,
          width: width,
        );
      }

      return Image.network(
        imageKey,
        height: height,
        width: width,
      );
    }

    if (imageKey.endsWith('.svg')) {
      return SvgPicture.asset(
        imageKey,
        height: height,
        width: width,
      );
    }

    return Image.asset(
      imageKey,
      height: height,
      width: width,
    );
  }
}

class AppIcon extends BaseImage {
  const AppIcon({
    required final String iconKey,
  }) : super(
          imageKey: iconKey,
          height: 56,
          width: 56,
        );
}

class DialogIcon extends BaseImage {
  const DialogIcon({
    required final String iconKey,
  }) : super(
          imageKey: iconKey,
          height: 64,
          width: 64,
        );
}

class SnackIcon extends BaseImage {
  const SnackIcon({
    required final String iconKey,
  }) : super(
          imageKey: iconKey,
          height: 35,
          width: 35,
        );
}

class FlexibleIcon extends BaseImage {
  const FlexibleIcon({
    super.key,
    required final String iconKey,
    required double height,
    double? width,
  }) : super(
          imageKey: iconKey,
          height: height,
          width: width ?? height,
        );
}

class BottomNavigationIcon extends BaseImage {
  const BottomNavigationIcon({
    super.key,
    required final String iconKey,
  }) : super(
          imageKey: iconKey,
          height: 24,
          width: 24,
        );
}

class SmallIcon extends BaseImage {
  const SmallIcon({
    super.key,
    required final String iconKey,
  }) : super(
          imageKey: iconKey,
          height: 16,
          width: 16,
        );
}

class CategoryIcon extends StatelessWidget {
  final String iconKey;
  final String colorHash;

  const CategoryIcon({
    super.key,
    required this.iconKey,
    required this.colorHash,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: hexToColor(colorHash),
      ),
      child: FlexibleIcon(
        iconKey: iconKey,
        height: 24,
      ),
    );
  }
}