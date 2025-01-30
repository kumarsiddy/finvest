import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
      {Key? key,
      required this.buttonText,
      required this.onPressFunction,
      required this.widthVal,
      this.heightVal = 0.06,
      this.radius = 30,
      this.primaryColor = AppTheme.primary,
      this.borderColor = AppTheme.primary,
      this.textColor = AppTheme.backgroundColor,
      this.isLoading = false})
      : super(key: key);

  final String buttonText;
  final VoidCallback? onPressFunction;
  final double widthVal;
  final double heightVal;
  final double radius;
  final Color primaryColor;
  final Color borderColor;
  final Color textColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    // Calculating dynamic sizes based on heightVal and widthVal
    double height = MediaQuery.of(context).size.height * heightVal;
    double width = MediaQuery.of(context).size.width / widthVal;

    return SizedBox(
        height: height,
        width: width,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              disabledBackgroundColor: primaryColor.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius), // <-- Radius
              ),
              side: BorderSide(
                width: onPressFunction == null ? 0 : height * 0.03,
                color: borderColor,
              )),
          onPressed: onPressFunction,
          child: isLoading
              ? SizedBox(
                  height: height * 0.4,
                  width: height * 0.4,
                  child: CircularProgressIndicator(
                    color: textColor,
                    strokeWidth: 2,
                  ))
              : Text(
                  buttonText,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: height * 0.35,
                      color: textColor),
                ),
        ));
  }
}
