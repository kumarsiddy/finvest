import 'package:flutter/material.dart';

abstract class SizeConfig {
  static late final double screenWidth;
  static late final double screenHeight;
  static late final double safeAreaScreenWidth;
  static late final double safeAreaScreenHeight;
  static late final double safeAreaScreenHeightWithoutToolbar;
  static late final double
      safeAreaScreenHeightWithoutToolAndBottomNavigationBar;
  static late final double blockSizeHorizontal;
  static late final double blockSizeVertical;
  static late final double devicePixelRatio;

  static late final double _safeAreaHorizontalUsed;
  static late final double _safeAreaVerticalUsed;

  static late final double safeBlockHorizontal;
  static late final double safeBlockVertical;

  static bool _firstTime = true;

  SizeConfig._();

  static void init(BuildContext context) {
    if (!_firstTime) {
      return;
    }

    final mediaQueryData = MediaQuery.of(context);
    screenWidth = mediaQueryData.size.width;
    screenHeight = mediaQueryData.size.height;
    devicePixelRatio = mediaQueryData.devicePixelRatio;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontalUsed =
        mediaQueryData.padding.left + mediaQueryData.padding.right;
    _safeAreaVerticalUsed =
        mediaQueryData.padding.top + mediaQueryData.padding.bottom;

    safeAreaScreenHeight = screenHeight - _safeAreaVerticalUsed;
    safeAreaScreenWidth = screenWidth - _safeAreaHorizontalUsed;

    safeBlockHorizontal = safeAreaScreenWidth / 100;
    safeBlockVertical = safeAreaScreenHeight / 100;

    safeAreaScreenHeightWithoutToolbar = safeAreaScreenHeight - kToolbarHeight;
    safeAreaScreenHeightWithoutToolAndBottomNavigationBar =
        safeAreaScreenHeight - kToolbarHeight - kBottomNavigationBarHeight;
    _firstTime = false;
  }
}
