import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BoxedText extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const BoxedText({
    super.key,
    required this.text,
    this.backgroundColor = AppTheme.primary,
    this.textColor = AppTheme.nearlyWhite,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
        child: Text(
          text,
          style: GoogleFonts.poppins(
              color: textColor, fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ),
    );
  }
}
