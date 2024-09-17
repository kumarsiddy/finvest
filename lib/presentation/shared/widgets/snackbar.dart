import 'package:finvest/presentation/core_app/design_library/app_colors.dart';
import 'package:finvest/presentation/shared/widgets/icon.dart';
import 'package:finvest/utils/image_keys.dart';
import 'package:finvest/utils/typedef.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Flushbar _getFlushBar(
  BuildContext context,
  String message, {
  required String iconKey,
  required Color backgroundColor,
  int? durationInSeconds,
  bool? dismissible,
  OnWidgetClickListener? onCloseListener,
}) {
  var buttonClickedFirstTime = false;
  return Flushbar(
    isDismissible: dismissible ?? true,
    message: message,
    icon: SnackIcon(
      iconKey: iconKey,
    ),
    duration: (dismissible ?? true)
        ? Duration(seconds: durationInSeconds ?? 2)
        : null,
    backgroundColor: backgroundColor,
    margin: const EdgeInsets.only(
      left: 16,
      right: 16,
      bottom: 24,
    ),
    padding: const EdgeInsets.all(24),
    borderRadius: BorderRadius.circular(
      19,
    ),
    mainButton: TextButton(
      onPressed: () {
        if (!buttonClickedFirstTime) {
          onCloseListener?.call(context);
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          buttonClickedFirstTime = true;
        }
      },
      child: FlexibleIcon(
        iconKey: ImageKeys.cross,
        height: 15.h,
        width: 15.h,
      ),
    ),
    boxShadows: [
      BoxShadow(
        color: backgroundColor.withOpacity(0.8),
        offset: const Offset(0, 2),
        blurRadius: 3,
      ),
    ],
  );
}

Future<void> _show(
  BuildContext context,
  String message, {
  required String iconKey,
  required Color backgroundColor,
  int? durationInSeconds,
  bool? dismissible,
  OnWidgetClickListener? onCloseListener,
}) async {
  final flushBar = _getFlushBar(
    context,
    message,
    durationInSeconds: durationInSeconds,
    iconKey: iconKey,
    backgroundColor: backgroundColor,
    dismissible: dismissible,
    onCloseListener: onCloseListener,
  );
  await flushBar.show(context);
}

Future<void> showInfoSnackbar(
  BuildContext context,
  String message, {
  bool? dismissible,
  OnWidgetClickListener? onCloseListener,
}) async {
  await _show(
    context,
    message,
    dismissible: dismissible,
    backgroundColor: AppColors.green,
    iconKey: ImageKeys.tick,
    onCloseListener: onCloseListener,
  );
}

Future<void> showErrorSnackbar(
  BuildContext context,
  String message, {
  bool? dismissible,
  OnWidgetClickListener? onCloseListener,
}) async {
  await _show(
    context,
    message,
    dismissible: dismissible,
    backgroundColor: AppColors.red,
    iconKey: ImageKeys.info,
    onCloseListener: onCloseListener,
  );
}
