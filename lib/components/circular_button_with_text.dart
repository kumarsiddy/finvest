import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CircularButtonWithText extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;

  const CircularButtonWithText({
    super.key,
    required this.onPressed,
    required this.text,
    required this.icon,
    this.backgroundColor = AppTheme.primary,
    this.iconColor = Colors.white,
    this.textColor = AppTheme.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
              elevation: MaterialStateProperty.resolveWith<double>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) return 0;
                  return 0;
                },
              ),
              backgroundColor: MaterialStateProperty.all(backgroundColor),
              shape: MaterialStateProperty.all(const CircleBorder()),
              padding: MaterialStateProperty.all(const EdgeInsets.all(15))),
          child: Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500, fontSize: 14, color: textColor),
        ),
      ],
    );
  }
}
