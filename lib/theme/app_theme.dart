import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF3856DD);
  static const Color primaryLight = Color(0xFF4A70FF);
  static const Color primaryDark = Color(0xFF2A3CA9);
  static const Color primaryVeryDark = Color(0xFF2B46C0);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color primarySoft = Color(0xFFEAEAF2);
  static const Color secondary = Color(0xFF0A0E2F);
  static const Color accent = Color(0xFFFABA3E);
  static const Color border = Color(0xFFD3D3E4);
  static const Color notWhite = Color(0xFFEDF0F2);
  static const Color nearlyWhite = Color(0xFFFFFFFF);
  static const Color nearlyBlue = Color(0xFF00B6F0);
  static const Color nearlyBlack = Color(0xFF213333);
  static const Color grey = Color(0xFF3A5160);
  static const Color inputBoxGrey = Color(0xFF9C9A9A);
  static const Color loadBoxGrey = Color(0xe0e0e0e0);
  static const Color nearlyGrey = Color(0xFFE0E0E0);
  static const Color red = Color(0xFFc7231e);

  static const Color darkText = Color(0xFF253840);
  static const Color darkerText = Color(0xFF17262A);
  static const Color lightText = Color(0xFF4A6572);
  static const Color deactivatedText = Color(0xFF767676);

  static Color shimmerBaseColor = Colors.grey[200]!;
  static Color shimmerHighlightColor = Colors.grey[100]!;

  static Color actionButton = AppTheme.primary;
  static const double cardElevation = 1;

  static TextStyle title = GoogleFonts.poppins(
      fontWeight: FontWeight.normal, fontSize: 22, color: darkerText);

  static TextStyle numberTitleText = GoogleFonts.poppins(
      fontWeight: FontWeight.w500, fontSize: 40, color: AppTheme.primary);

  static TextStyle numberSubText = GoogleFonts.poppins(
      color: AppTheme.secondary, fontWeight: FontWeight.w500, fontSize: 18);

  static TextStyle numberSmallText = GoogleFonts.poppins(
      fontWeight: FontWeight.w600, fontSize: 24, color: AppTheme.primary);

  static TextStyle sectionTitleText = GoogleFonts.poppins(
      fontWeight: FontWeight.w600, fontSize: 18, color: AppTheme.primary);

  static TextStyle sectionSmallText = GoogleFonts.poppins(
      fontWeight: FontWeight.w500, fontSize: 14, color: AppTheme.primary);

  static TextStyle titleTextPrimary = GoogleFonts.poppins(
      fontWeight: FontWeight.w600, fontSize: 20, color: AppTheme.secondary);

  static TextStyle titleText = GoogleFonts.poppins(
      fontWeight: FontWeight.w600, fontSize: 20, color: AppTheme.secondary);

  static TextStyle headingText = GoogleFonts.poppins(
      fontWeight: FontWeight.w600, fontSize: 20, color: AppTheme.secondary);

  static TextStyle headingSmallText =
      GoogleFonts.poppins(fontSize: 16, color: AppTheme.secondary);

  static TextStyle secondaryTextBold = GoogleFonts.poppins(
      fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.secondary);

  static TextStyle secondaryText = GoogleFonts.poppins(
      fontSize: 14, color: AppTheme.secondary.withOpacity(0.7));

  static TextStyle disclosureText = GoogleFonts.poppins(
      fontSize: 12, color: AppTheme.secondary.withOpacity(0.5));

  static TextStyle titleLarge = GoogleFonts.poppins(
      fontWeight: FontWeight.w700, fontSize: 35, color: AppTheme.secondary);

  static TextStyle sectionTitle = GoogleFonts.poppins(
      fontWeight: FontWeight.w600, fontSize: 18, color: AppTheme.secondary);

  static TextStyle sectionTitleNormal = GoogleFonts.poppins(
      fontWeight: FontWeight.w400, fontSize: 18, color: AppTheme.secondary);

  static TextStyle sectionSmallTitle = GoogleFonts.poppins(
      fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.secondary);

  static TextStyle sectionSubTitle = GoogleFonts.poppins(
      fontSize: 12, color: AppTheme.secondary.withOpacity(0.5));

  static TextStyle bodyBold = GoogleFonts.poppins(
      fontWeight: FontWeight.w600, fontSize: 16, color: AppTheme.secondary);

  static TextStyle bodyNormal = GoogleFonts.poppins(
      fontWeight: FontWeight.w500, fontSize: 14, color: AppTheme.secondary);

  static TextStyle bodyNormalGrey = GoogleFonts.poppins(
      fontWeight: FontWeight.w500,
      fontSize: 14,
      color: AppTheme.secondary.withOpacity(0.6));

  static TextStyle bodyNormalWhite = GoogleFonts.poppins(
      fontWeight: FontWeight.w500, fontSize: 16, color: AppTheme.nearlyWhite);

  static TextStyle actionPageTitle = GoogleFonts.poppins(
      fontWeight: FontWeight.w500, fontSize: 18, color: AppTheme.secondary);

  static TextStyle profileText = GoogleFonts.poppins(
      color: AppTheme.secondary, fontWeight: FontWeight.w500, fontSize: 15);

  static TextStyle subBodyNormalBold = GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      fontSize: 12,
      color: AppTheme.secondary.withOpacity(0.6));

  static TextStyle subBodyDark = GoogleFonts.poppins(
      fontWeight: FontWeight.w500,
      fontSize: 12,
      color: AppTheme.secondary.withOpacity(0.6));

  static TextStyle subBodyNormal = GoogleFonts.poppins(
      fontWeight: FontWeight.w400,
      fontSize: 12,
      color: AppTheme.secondary.withOpacity(0.6));

  static TextStyle subBodyNormalGreen = GoogleFonts.poppins(
      color: Colors.green, fontWeight: FontWeight.w600, fontSize: 12);

  static TextStyle warningMessage = GoogleFonts.poppins(
      fontWeight: FontWeight.w500, fontSize: 12, color: Colors.red);

  static TextStyle bodyNormalLight =
      GoogleFonts.poppins(fontSize: 16, color: AppTheme.secondary);

  static TextStyle bulletBold = GoogleFonts.poppins(
      fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.secondary);

  static TextStyle bulletNormal = GoogleFonts.poppins(
      fontWeight: FontWeight.normal, fontSize: 14, color: AppTheme.secondary);

  static AppBarTheme appBarTheme = AppBarTheme(
    color: backgroundColor,
    titleTextStyle: title,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
  );

  static TabBarTheme tabBarTheme = TabBarTheme(
    labelColor: primary,
    labelStyle: bodyBold,
    unselectedLabelColor: darkerText,
    unselectedLabelStyle: bodyBold,
  );

  static BottomNavigationBarThemeData bottomNavigationBarTheme =
      BottomNavigationBarThemeData(
          selectedItemColor: primary,
          selectedLabelStyle: bodyBold,
          unselectedLabelStyle: bodyNormal);

  static ThemeData get light {
    return ThemeData(
        useMaterial3: false,
        primaryColor: primary,
        appBarTheme: appBarTheme,
        tabBarTheme: tabBarTheme,
        bottomNavigationBarTheme: bottomNavigationBarTheme);
  }
}
