import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SellConfirmationPopover extends StatelessWidget {
  const SellConfirmationPopover({Key? key, required this.sellAmount})
      : super(key: key);

  final String sellAmount;

  @override
  Widget build(BuildContext context) {
    // Determine the number of shares from the sellAmount
    final numShares = double.tryParse(sellAmount) ?? 0;
    final shareText = numShares == 1 ? "share" : "shares";

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
            // Navigator.pushReplacement(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => NavigatorScreen(
            //         selectedIndex: 0,
            //       ),
            //     ));
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
            "Sell Order Initiated",
            textAlign: TextAlign.center,
            style: AppTheme.headingText,
          ),
          const SizedBox(height: 10),
          Text(
            "Your order to sell $sellAmount $shareText of treasury bill has been initiated."
            " Orders are processed on weekdays during regular bond market trading hours (9:30 AM - 4:00 PM EST, Monday - Friday).",
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
