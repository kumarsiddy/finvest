import 'package:bondgrid/screens/home/navigator_screen.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountFailureVerificationPopover extends StatelessWidget {
  const AccountFailureVerificationPopover({Key? key}) : super(key: key);

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
            child: Icon(Icons.recent_actors_rounded,
                size: MediaQuery.of(context).size.height * 0.06,
                color: AppTheme.primary)),
      ]),
      content: SingleChildScrollView(
          child: Column(
        children: [
          Text(
            "Additional Information Required",
            textAlign: TextAlign.center,
            style: AppTheme.headingText,
          ),
          const SizedBox(height: 10),
          Text(
            "We need more information to verify your account details."
            " This will only take a couple of minutes.",
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
