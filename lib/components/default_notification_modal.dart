import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bondgrid/components/custom_button.dart';
import 'package:bondgrid/screens/home/layout_config.dart';
import 'package:bondgrid/theme/app_theme.dart';

class DefaultNotificationModal extends StatelessWidget {
  final Color textColor;
  final Color imageBackgroundColor;
  final Color backgroundColor;
  final String title;
  final String bodyText;
  final String? buttonText;
  final VoidCallback? onPressed;
  final String? localImagePath;
  final String? imageUrl;

  const DefaultNotificationModal({
    super.key,
    this.textColor = AppTheme.primary,
    this.imageBackgroundColor = AppTheme.nearlyWhite,
    this.backgroundColor = AppTheme.nearlyWhite,
    required this.title,
    required this.bodyText,
    this.buttonText,
    this.onPressed,
    this.localImagePath,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
            if (localImagePath != null || imageUrl != null)
              ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: _buildImage(context)),
            Positioned(
              left: 10,
              top: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(2),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.clear,
                    color: textColor,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
        Container(
          color: backgroundColor,
          padding: EdgeInsets.only(
            top: 25,
            bottom: LayoutConfig().bottomPadding + 20,
            left: 15,
            right: 15,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                textAlign: TextAlign.start,
                style: GoogleFonts.poppins(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 20),
              ),
              const SizedBox(height: 10),
              Text(
                bodyText,
                textAlign: TextAlign.start,
                style: GoogleFonts.poppins(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14),
              ),
              if (buttonText != null && onPressed != null)
                const SizedBox(height: 25),
              if (buttonText != null && onPressed != null)
                CustomButton(
                  widthVal: 1,
                  buttonText: buttonText!,
                  onPressFunction: onPressed,
                  primaryColor: textColor,
                  borderColor: textColor,
                  textColor: backgroundColor,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImage(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (localImagePath != null) {
      if (localImagePath!.endsWith('.svg')) {
        return SvgPicture.asset(
          localImagePath!,
          width: screenWidth,
          fit: BoxFit.fill,
        );
      } else {
        return Image.asset(
          localImagePath!,
          width: screenWidth,
          fit: BoxFit.fill,
        );
      }
    } else if (imageUrl != null) {
      if (imageUrl!.endsWith('.svg')) {
        return SvgPicture.network(
          imageUrl!,
          width: screenWidth,
          fit: BoxFit.fill,
        );
      } else {
        return Image.network(
          imageUrl!,
          width: screenWidth,
          fit: BoxFit.fill,
        );
      }
    }

    return Container();
  }
}
