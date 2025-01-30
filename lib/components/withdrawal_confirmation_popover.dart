import 'package:bondgrid/models/transaction.dart';
import 'package:bondgrid/screens/home/navigator_screen.dart';
import 'package:bondgrid/screens/transactions/transaction_detail_screen.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:bondgrid/utilities/format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WithdrawalConfirmationPopover extends StatelessWidget {
  const WithdrawalConfirmationPopover(
      {super.key, required this.withdrawalAmount, this.transaction});

  final String withdrawalAmount;
  final Transaction? transaction;

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
            if (transaction != null) {
              Navigator.push(
                  context,
                  (Theme.of(context).platform == TargetPlatform.iOS)
                      ? CupertinoPageRoute(
                          builder: (context) => TransactionDetailScreen(
                                transaction: transaction!,
                              ))
                      : MaterialPageRoute(
                          builder: (context) => TransactionDetailScreen(
                                transaction: transaction!,
                              )));
            }
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
            "Withdrawal Initiated",
            textAlign: TextAlign.center,
            style: AppTheme.headingText,
          ),
          const SizedBox(height: 10),
          Text(
            "Your ${formatAmount(withdrawalAmount)} transfer to your bank has been initiated."
            " This transfer may take up to 5 business days to complete.",
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
