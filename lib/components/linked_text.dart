import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LinkedText extends StatelessWidget {
  final Color textColor;
  final String buttonText;
  final VoidCallback? onPressed;

  const LinkedText(
      {super.key,
      this.textColor = AppTheme.primary,
      required this.buttonText,
      this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: textColor,
        padding: const EdgeInsets.all(0),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onPressed,
      child: Container(
        margin: const EdgeInsets.all(0),
        padding: const EdgeInsets.only(bottom: 1.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: textColor,
              width: 1.0,
            ),
          ),
        ),
        child: Text(
          buttonText,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, fontSize: 12, color: textColor),
        ),
      ),
    );
  }
}
