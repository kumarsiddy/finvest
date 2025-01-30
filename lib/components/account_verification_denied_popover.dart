import 'package:bondgrid/screens/home/navigator_screen.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountVerificationDeniedPopover extends StatelessWidget {
  const AccountVerificationDeniedPopover({Key? key}) : super(key: key);

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
            // Navigator.pushReplacement(
            //   context,
            //   PageRouteBuilder(
            //     pageBuilder: (context, animation1, animation2) =>
            //         NavigatorScreen(selectedIndex: 0),
            //     transitionDuration:
            //         Duration.zero, // Specify no transition duration
            //     reverseTransitionDuration: Duration.zero,
            //   ),
            // );
            navigatorScreenStateKey.currentState?.resetToScreen(0);
          },
          child: Text(
            "Got it",
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: AppTheme.nearlyWhite),
          ),
        ));
    // set up the AlertDialog
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30), // <-- Radius
      ),
      icon: Stack(children: [
        Center(
            child: Icon(Icons.cancel_outlined,
                size: MediaQuery.of(context).size.height * 0.06,
                color: Colors.red)),
      ]),
      content: SingleChildScrollView(
          child: Column(
        children: [
          Text(
            "Your account could not be verified.",
            textAlign: TextAlign.center,
            style: AppTheme.headingText,
          ),
          const SizedBox(height: 10),
          Text(
            "We're sorry but your account could not be approved at this time."
            " Please contact us at support@getfinvest.com for more information.",
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
