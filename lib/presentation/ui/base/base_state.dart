import 'dart:async';

import 'package:bondgrid/di/injection.dart';
import 'package:bondgrid/domain/models/connection_status.dart';
import 'package:bondgrid/presentation/base/base_bloc.dart';
import 'package:bondgrid/presentation/base/common_bloc.dart';
import 'package:bondgrid/presentation/ui/base/app_life_cycle_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BaseState<SW extends StatefulWidget> extends State<SW>
    with RouteAware {
  late final AppLifeCycleObserver appLifeCycleObserver;
  late final CommonBloc _commonBloc;

  Map<String, dynamic>? argsFromPreviousRoute;
  List<BlocProvider>? _blocProviders;

  @override
  void initState() {
    _blocProviders = getBlocProviders();

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
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    argsFromPreviousRoute = _getArgsFromContext(context);
  }

  Map<String, dynamic>? _getArgsFromContext(
    BuildContext context,
  ) {
    return ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => _commonBloc,
        ),
        if (_blocProviders != null) ..._blocProviders!,
      ],
      child: _buildScreen(context),
    );
  }

  List<BlocProvider>? getBlocProviders() {
    return null;
  }

  BlocProvider<T> createBlocProvider<T extends BaseBloc>({
    bool isMain = false,
  }) {
    final bloc = getIt<T>()..init();
    if (isMain) {
      _commonBloc = bloc.commonBloc;
    }
    return BlocProvider<T>(create: (_) => bloc);
  }

  // TODO:: Need to define proper color here
  Color get statusBarColor => Colors.white;

  void onConnectivityChange(
    BuildContext context,
    ConnectionStatus status,
  ) {
    // TODO:: Either restart the bloc or put some logic to handle this case
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
        if (state is ConnectivityState)
          !state.status.working
              // TODO:: Need to put proper no connection page here
              ? const SizedBox.shrink()
              : const SizedBox.shrink(),
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
    // TODO: Handle exception here
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(
      appLifeCycleObserver,
    );
    onDestroy(context);
    super.dispose();
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
