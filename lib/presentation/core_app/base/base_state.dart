import 'dart:async';

import 'package:finvest/di/injection.dart';
import 'package:finvest/domain/interfaces/i_connection_aware_facade.dart';
import 'package:finvest/infrastructure/api_services/errors.dart';
import 'package:finvest/presentation/application/base/base_bloc.dart';
import 'package:finvest/presentation/application/base/common_bloc.dart';
import 'package:finvest/presentation/application/models/connection_status.dart';
import 'package:finvest/presentation/core_app/base/app_life_cycle_observer.dart';
import 'package:finvest/presentation/core_app/base/base_view_controller.dart';
import 'package:finvest/presentation/core_app/base/size_config.dart';
import 'package:finvest/presentation/core_app/router/route_handler.dart';
import 'package:finvest/presentation/shared/app_colors.dart';
import 'package:finvest/presentation/shared/screens/double_press_to_exit.dart';
import 'package:finvest/presentation/shared/screens/spinkit_loader.dart';
import 'package:finvest/presentation/shared/widgets/snackbar.dart';
import 'package:finvest/utils/app_utils.dart';
import 'package:finvest/utils/extensions.dart';
import 'package:finvest/utils/string_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'no_internet_page.dart';

abstract class BaseState<
    SW extends StatefulWidget,
    VC extends BaseViewController,
    B extends BaseBloc> extends State<SW> with RouteAware {
  late final AppLifeCycleObserver appLifeCycleObserver;

  B? _bloc;
  VC? _viewController;
  Map<String, dynamic>? argsFromPreviousRoute;

  @override
  void initState() {
    _bloc = getImplementedBloc(context);
    appLifeCycleObserver = AppLifeCycleObserver(
      suspendingCallBack: () async {
        onSuspend(context);
      },
      resumeCallBack: () async {
        if (!mounted) return;
        onResume(context);
      },
    );
    WidgetsBinding.instance.addObserver(
      appLifeCycleObserver,
    );
    onStart(context);
    _viewController?.init();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initializing SizeConfig for the first time
    SizeConfig.init(context);
    argsFromPreviousRoute = getArgsFromContext(context);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        if (_bloc != null)
          BlocProvider(
            create: (_) => _bloc!,
          ),
        if (_bloc != null)
          BlocProvider(
            create: (_) => _bloc!.commonBloc,
          )
      ],
      child: _buildScreen(context),
    );
  }

  Color get statusBarColor => AppColors.white;

  bool get forceRefreshOnConnectionChange => false;

  void onConnectivityChange(
    BuildContext context,
    ConnectionStatus status,
  ) {
    if (forceRefreshOnConnectionChange && status.working) {
      context.started<B>();
    }
  }

  /// This method will be called when widget will be started
  @mustCallSuper
  Future<void> onStart(BuildContext context) async {
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
  ) async {}

  /// This is lifecycle call for the app, not for this widget
  Future<void> onSuspend(
    BuildContext context,
  ) async {}

  /// This method will be called when widget will be destroyed
  Future<void> onDestroy(
    BuildContext context,
  ) async {}

  Widget _buildScreen(BuildContext context) {
    return BlocConsumer<CommonBloc, CommonState>(
      builder: _handleChild,
      listener: _handleState,
    );
  }

  Widget _handleChild(
    BuildContext context,
    CommonState state,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        buildWidget(context),
        if (state is LoaderState)
          state.loading ? const SpinkitLoader() : const SizedBox.shrink(),
        // if (state is ConnectivityState)
        //   !state.status.working ? _NoInternetPage() : const SizedBox.shrink(),
      ],
    );
  }

  Widget buildWidget(BuildContext context);

  void _handleState(
    BuildContext context,
    CommonState state,
  ) {
    switch (state) {
      case ConnectivityState():
        _handleOnConnectivityChange(
          context,
          state,
        );
        break;
      case ExceptionState():
        _handleExceptionState(
          context,
          state.exception,
        );
      default:
      // nothing to do here
    }
  }

  void _handleOnConnectivityChange(
    BuildContext context,
    ConnectivityState store,
  ) {
    if (!mounted) return;
    onConnectivityChange(context, store.status);
  }

  Future<void> _handleExceptionState(
    BuildContext context,
    Exception exception,
  ) async {
    final exceptionType = exception.runtimeType;
    if (exceptionType == ServerException) {
      showErrorSnackbar(
        context,
        (exception as ServerException).message ?? StringKeys.someErrorOccurred,
      );
    } else if (exceptionType == UnknownServerException) {
      showErrorSnackbar(
        context,
        (exception as UnknownServerException).message,
      );
    } else {
      //TODO:: Log the crash
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(
      appLifeCycleObserver,
    );
    onDestroy(context);
    _viewController?.dispose();
    super.dispose();
  }

  B? getImplementedBloc(
    BuildContext context,
  ) {
    return getIt<B>()..init();
  }

  VC? getViewController() {
    return getIt<VC>()..init();
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
