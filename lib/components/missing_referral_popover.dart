import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MissingReferralPopover extends StatelessWidget {
  const MissingReferralPopover({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30), // <-- Radius
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
            "Your missing referral request has been received.",
            style: AppTheme.bodyNormal,
            textAlign: TextAlign.center,
          )
        ],
      )),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.only(bottom: 20),
      actions: [confirmButton(context)],
    );
  }

  Widget confirmButton(BuildContext context) {
    return SizedBox(
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
            style: AppTheme.bodyNormalWhite,
          ),
        ));
  }
}
