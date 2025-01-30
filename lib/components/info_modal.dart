import 'package:bondgrid/screens/home/layout_config.dart';
import 'package:flutter/material.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:bondgrid/components/custom_button.dart';

void showInfoModal({
  required BuildContext context,
  required String title,
  required dynamic subtext,
  bool isNavBarVisible = false,
  VoidCallback? onClose,
}) {
  showModalBottomSheet(
    isDismissible: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    context: context,
    builder: (BuildContext context) {
      return NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: InfoModalSheet(
              title: title,
              subtext: subtext,
              isNavBarVisible: isNavBarVisible));
    },
  ).then((_) {
    if (onClose != null) {
      onClose();
    }
  });
}

class InfoModalSheet extends StatelessWidget {
  final String title;
  final dynamic subtext;
  final bool isNavBarVisible;

  const InfoModalSheet(
      {super.key,
      required this.title,
      required this.subtext,
      this.isNavBarVisible = false});

  @override
  Widget build(BuildContext context) {
    // If the keyboard is visible, use the keyboard's height as the bottom padding
    double bottomPadding =
        MediaQuery.of(context).viewInsets.bottom > 0 || isNavBarVisible
            ? 20
            : LayoutConfig().bottomPadding + 20;

    return ListView(
      shrinkWrap: true,
      children: [
        ListTile(
          title: Text(title,
              style: AppTheme.bodyBold, textAlign: TextAlign.center),
        ),
        ListTile(
          title: subtext is String
              ? Text(
                  subtext,
                  textAlign: TextAlign.center,
                  style: AppTheme.subBodyNormal,
                )
              : DefaultTextStyle(
                  style: AppTheme.subBodyNormal,
                  textAlign: TextAlign.center,
                  child: subtext,
                ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding),
          child: CustomButton(
            widthVal: 1,
            buttonText: 'Got it',
            onPressFunction: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }
}
