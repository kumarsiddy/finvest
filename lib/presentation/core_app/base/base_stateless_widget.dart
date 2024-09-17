import 'dart:async';

import 'package:finvest/di/injection.dart';
import 'package:finvest/domain/interfaces/i_connection_aware_facade.dart';
import 'package:finvest/infrastructure/api_services/errors.dart';
import 'package:finvest/presentation/application/base/base_bloc.dart';
import 'package:finvest/presentation/application/models/connection_status.dart';
import 'package:finvest/presentation/core_app/base/app_life_cycle_observer.dart';
import 'package:finvest/presentation/core_app/base/size_config.dart';
import 'package:finvest/presentation/core_app/design_library/app_colors.dart';
import 'package:finvest/presentation/core_app/router/route_handler.dart';
import 'package:finvest/presentation/shared/screens/double_press_to_exit.dart';
import 'package:finvest/presentation/shared/screens/spinkit_loader.dart';
import 'package:finvest/presentation/shared/widgets/snackbar.dart';
import 'package:finvest/utils/app_utils.dart';
import 'package:finvest/utils/extensions.dart';
import 'package:finvest/utils/string_keys.dart';
import 'package:finvest/utils/typedef.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'base_stateful_widget.dart';
part 'no_internet_page.dart';

abstract class BaseStatelessWidget<B extends BaseBloc> extends StatelessWidget
    with RouteAware {
  final wrapper = _BaseStatelessInitWrapper<B>();

  BaseStatelessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final argsFromPreviousRoute = getArgsFromContext(context);
    if (wrapper.isFirstTime) {
      final childBloc = getImplementedBloc(
        context,
        argsFromPreviousRoute,
      );
      wrapper
        ..childBloc = childBloc
        ..isFirstTime = false;
    }

    return MultiBlocProvider(
      providers: [
        if (wrapper.childBloc != null)
          BlocProvider(
            create: (_) => wrapper.childBloc!,
          ),
      ],
      child: _BaseStatefulWidget<B>(
        onStart: (ctx) => onStart(
          ctx,
          argsFromPreviousRoute,
        ),
        onResume: (ctx) => onResume(
          ctx,
          argsFromPreviousRoute,
        ),
        onSuspend: onSuspend,
        onDestroy: onDestroy,
        onConnectivityChange: onConnectivityChange,
        args: argsFromPreviousRoute,
        builder: buildScreen,
      ),
    );
  }

  Color get statusBarColor => AppColors.white;

  bool get forceRefreshOnConnectionChange => false;

  void onConnectivityChange(
    BuildContext context,
    ConnectionStatus status,
  ) {
    if (forceRefreshOnConnectionChange && status.working) {
      final args = getArgsFromContext(context);
      context.started<B>(args);
    }
  }

  /// This method will be called when widget will be started
  @mustCallSuper
  Future<void> onStart(
    BuildContext context,
    Map<String, dynamic>? args,
  ) async {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: statusBarColor,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  /// This is lifecycle call for the app, not for this widget
  Future<void> onResume(
    BuildContext context,
    Map<String, dynamic>? args,
  ) async {}

  /// This is lifecycle call for the app, not for this widget
  Future<void> onSuspend(
    BuildContext context,
  ) async {}

  /// This method will be called when widget will be destroyed
  Future<void> onDestroy(
    BuildContext context,
  ) async {}

  Widget buildScreen(BuildContext context);

  B? getImplementedBloc(
    BuildContext context,
    Map<String, dynamic>? args,) {
    return getIt<B>()
      ..started(args);
  }

  /// Called when the top route has been popped off, and the current route
  /// shows up.
  @override
  void didPopNext() {}

  /// Called when the current route has been pushed.
  @override
  void didPush() {}

  /// Called when the current route has been popped off.
  @override
  void didPop() {}

  /// Called when a new route has been pushed, and the current route is no
  /// longer visible.
  @override
  void didPushNext() {}
}

class _BaseStatelessInitWrapper<T> {
  bool isFirstTime = true;
  T? childBloc;
}
