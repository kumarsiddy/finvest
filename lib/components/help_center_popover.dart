import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpCenterPopover extends StatelessWidget {
  const HelpCenterPopover({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // set up the buttons
    Widget confirmButton = SizedBox(
        height: MediaQuery.of(context).size.height * 0.06,
        width: MediaQuery.of(context).size.width * 0.5,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // <-- Radius
            ),
          ),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          child: Text(
            "Got it",
            style: AppTheme.bodyNormalWhite,
          ),
        ));
    // set up the AlertDialog
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30), // <-- Radius
      ),
      icon: Stack(children: [
        Center(
            child: SvgPicture.asset('lib/assets/support.svg',
                height: MediaQuery.of(context).size.height * 0.06,
                width: MediaQuery.of(context).size.height * 0.06,
                color: AppTheme.primary)),
      ]),
      content: SingleChildScrollView(
          child: Column(
        children: [
          // Text(
          //   "",
          //   textAlign: TextAlign.center,
          //   style: AppTheme.headingText,
          // ),
          // const SizedBox(height: 10),
          Text(
            "Please contact us at support@getfinvest.com and we will get back to you promptly.",
            style: AppTheme.bodyNormal,
            textAlign: TextAlign.center,
          )
        ],
      )),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.only(bottom: 20),
      actions: [confirmButton],
    );
  }
}
