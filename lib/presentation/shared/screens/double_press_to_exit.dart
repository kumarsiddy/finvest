import 'dart:async';

import 'package:finvest/presentation/core_app/design_library/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DoublePressToExit extends StatefulWidget {
  final Widget child;
  final bool isDashboard;

  const DoublePressToExit({
    super.key,
    required this.child,
    this.isDashboard = false,
  });

  @override
  DoublePressToExitState createState() => DoublePressToExitState();
}

class DoublePressToExitState extends State<DoublePressToExit> {
  int? _lastTimeBackButtonWasTapped;
  static const exitTimeInMillis = 2000;

  bool get _isAndroid => Theme.of(context).platform == TargetPlatform.android;

  @override
  Widget build(BuildContext context) {
    if (_isAndroid) {
      return WillPopScope(
        onWillPop: () => _handleWillPop(
          context,
        ),
        child: widget.child,
      );
    } else {
      return widget.child;
    }
  }

  Future<bool> _handleWillPop(
    BuildContext context,
  ) async {
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    if (_lastTimeBackButtonWasTapped != null &&
        (currentTime - _lastTimeBackButtonWasTapped!) < exitTimeInMillis) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      await SystemNavigator.pop();
      return false;
    } else {
      _lastTimeBackButtonWasTapped = DateTime.now().millisecondsSinceEpoch;
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        _getExitSnackBar(context),
      );
      return false;
    }
  }

  SnackBar _getExitSnackBar(
    BuildContext context,
  ) {
    return const SnackBar(
      content: Text('Please Press Back Again to exit'),
      backgroundColor: AppColors.red,
      duration: Duration(
        seconds: 2,
      ),
      behavior: SnackBarBehavior.floating,
    );
  }
}
