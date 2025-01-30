import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BankAddConfirmationPopover extends StatelessWidget {
  const BankAddConfirmationPopover({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget confirmButton = SizedBox(
        height: MediaQuery.of(context).size.height * 0.06,
        width: MediaQuery.of(context).size.width * 0.5,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
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
        borderRadius: BorderRadius.circular(30),
      ),
      icon: Stack(children: [
        Center(
            child: Icon(Icons.check_circle_outline,
                size: MediaQuery.of(context).size.height * 0.06,
                color: Colors.green)),
      ]),
      content: SingleChildScrollView(
          child: Column(
        children: [
          Text(
            "You have successfully linked your bank account",
            textAlign: TextAlign.center,
            style: AppTheme.headingText,
          ),
          const SizedBox(height: 10),
          Text(
            "You can invest in US Treasuries directly or move money to the Finvest Cash account"
            " from your bank account securely.",
            style: AppTheme.bodyNormal,
            textAlign: TextAlign.center,
          )
          // Text(
          //   "You can now move money between your Finvest account"
          //   " and your bank account securely.",
          //   style: AppTheme.bodyNormal,
          //   textAlign: TextAlign.center,
          // )
        ],
      )),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.only(bottom: 20),
      actions: [confirmButton],
    );
  }
}
