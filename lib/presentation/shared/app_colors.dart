import 'package:flutter/material.dart';

abstract class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF3856DD);
  static const Color primaryBackground = Color(0xFFF4F7FC);
  static const Color primaryDark = Color(0xFF071A34);

  /// Text Colors
  static const Color textPrimary = Color(0xFF071A34);
  static const Color textSecondary = Color(0xFF696D70);
  static const Color textTertiary = Color(0xFF999EA3);

  /// Grey Colors
  static const Color grey = Color(0xFFC9CDD1);
  static const Color greyLight = Color(0xFFF5F7FA);
  static const Color greyDark = Color(0xFFB8BBBF);

  /// White Color
  static const Color white = Color(0xFFFFFFFF);

  /// transparent
  static const Color transparent = Colors.transparent;

  /// Black Color
  static const blackTransparent = Colors.black12;
  static const black = Colors.black;

  /// Informational Colors
  /// Red Colors
  static const Color red = Color(0xFFD13B3B);
  /// Green Colors
  static const Color green = Color(0xFF2C9E82);
}
