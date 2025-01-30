import 'package:bondgrid/bloc/home_bloc.dart';
import 'package:bondgrid/models/transaction.dart';
import 'package:bondgrid/screens/home/navigator_screen.dart';
import 'package:bondgrid/screens/transactions/transaction_detail_screen.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:bondgrid/utilities/format.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bondgrid/repo/home_repo.dart';
import 'package:bondgrid/screens/trading/holding_detail_screen.dart';

class PurchaseConfirmationPopover extends StatelessWidget {
  const PurchaseConfirmationPopover(
      {super.key,
      required this.purchaseAmount,
      this.holdingId,
      this.transaction});

  final String purchaseAmount;
  final String? holdingId;
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
            //Navigator.pop(context);
            if (holdingId != null) {
              Navigator.push(
                  context,
                  (Theme.of(context).platform == TargetPlatform.iOS)
                      ? CupertinoPageRoute(
                          builder: (context) => BlocProvider(
                              create: (context) => HomeBloc(HomeRepo()),
                              child: HoldingDetailScreen(
                                holdingId: holdingId!,
                              )))
                      : MaterialPageRoute(
                          builder: (context) => BlocProvider(
                              create: (context) => HomeBloc(HomeRepo()),
                              child: HoldingDetailScreen(
                                holdingId: holdingId!,
                              ))));
            } else if (transaction != null) {
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
            "Purchase Order Initiated",
            textAlign: TextAlign.center,
            style: AppTheme.headingText,
          ),
          const SizedBox(height: 10),
          Text(
            "Your ${formatAmount(purchaseAmount)} order to buy treasury bill has been initiated."
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
