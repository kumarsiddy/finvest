import 'package:bondgrid/components/custom_button.dart';
import 'package:bondgrid/components/linked_text.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class DefaultNotificationCard extends StatelessWidget {
  final Color iconColor;
  final Color textColor;
  final Color backgroundColor;
  final ImageProvider? backgroundImage;
  final IconData? icon;
  final String title;
  final String bodyText;
  final String? buttonText;
  final VoidCallback? onPressed;
  final bool textButton;
  final VoidCallback onCancel;
  final String? localImagePath;
  final String? imageUrl;

  const DefaultNotificationCard({
    super.key,
    this.iconColor = AppTheme.nearlyWhite,
    this.textColor = AppTheme.nearlyWhite,
    this.backgroundColor = AppTheme.primary,
    this.backgroundImage,
    this.icon,
    required this.title,
    required this.bodyText,
    this.buttonText,
    this.onPressed,
    required this.onCancel,
    this.textButton = false,
    this.localImagePath,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: AppTheme.cardElevation,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
            decoration: BoxDecoration(
                gradient: backgroundImage == null
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          backgroundColor,
                          backgroundColor.withOpacity(0.9),
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(15),
                image: backgroundImage != null
                    ? DecorationImage(
                        image: backgroundImage!,
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                            backgroundColor.withOpacity(
                                0.5), // Apply a color filter to enhance text visibility
                            BlendMode.dstATop),
                      )
                    : null),
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (localImagePath != null || imageUrl != null)
                Expanded(
                  flex: 2,
                  child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.fromLTRB(5, 10, 0, 10),
                        child: _buildImage(context),
                      )),
                ),
              Expanded(
                  flex: (localImagePath != null || imageUrl != null) ? 8 : 10,
                  child: Container(
                      padding: const EdgeInsets.fromLTRB(5, 10, 0, 10),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (icon != null &&
                                      localImagePath == null &&
                                      imageUrl == null)
                                    Icon(icon,
                                        size:
                                            MediaQuery.of(context).size.height *
                                                0.04,
                                        color: iconColor),
                                  if (icon != null &&
                                      localImagePath == null &&
                                      imageUrl == null)
                                    const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          title,
                                          style: GoogleFonts.poppins(
                                              color: textColor,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          bodyText,
                                          style: GoogleFonts.poppins(
                                              color: textColor,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12),
                                        ),
                                        if (textButton &&
                                            buttonText != null &&
                                            onPressed != null)
                                          const SizedBox(
                                            height: 15,
                                          ),
                                        if (textButton &&
                                            buttonText != null &&
                                            onPressed != null)
                                          LinkedText(
                                              buttonText: buttonText!,
                                              textColor: textColor,
                                              onPressed: onPressed!)
                                      ],
                                    ),
                                  ),
                                ]),
                            if (!textButton &&
                                buttonText != null &&
                                onPressed != null)
                              const SizedBox(
                                height: 15,
                              ),
                            if (!textButton &&
                                buttonText != null &&
                                onPressed != null)
                              CustomButton(
                                widthVal: 1,
                                buttonText: buttonText!,
                                onPressFunction: onPressed,
                                primaryColor: textColor,
                                borderColor: textColor,
                                textColor: backgroundColor,
                              )
                          ]))),
              IconButton(
                  onPressed: onCancel,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.close,
                    size: MediaQuery.of(context).size.height * 0.02,
                    color: iconColor,
                  )),
            ])));
  }

  Widget _buildImage(BuildContext context) {
    if (localImagePath != null) {
      if (localImagePath!.endsWith('.svg')) {
        return SvgPicture.asset(
          localImagePath!,
          width: MediaQuery.of(context).size.width * 0.1,
          color: textColor,
        );
      } else {
        return Image.asset(
          localImagePath!,
          width: MediaQuery.of(context).size.width * 0.1,
        );
      }
    } else if (imageUrl != null) {
      if (imageUrl!.endsWith('.svg')) {
        return SvgPicture.network(
          imageUrl!,
          width: MediaQuery.of(context).size.width * 0.1,
          color: textColor,
        );
      } else {
        return Image.network(
          imageUrl!,
          width: MediaQuery.of(context).size.width * 0.1,
        );
      }
    }

    return Container();
  }
}
