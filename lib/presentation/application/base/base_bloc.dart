import 'package:finvest/infrastructure/api_services/logger.dart';
import 'package:finvest/presentation/application/base/common_bloc.dart';
import 'package:finvest/presentation/application/models/connection_status.dart';
import 'package:finvest/presentation/application/models/state_stores.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'common_event.dart';
part 'common_state.dart';

abstract class BaseBloc<Event, State> extends Bloc<Event, State> {
  final CommonBloc _commonBloc;

  BaseBloc(
    this._commonBloc,
    State initialState,
  ) : super(initialState) {
    handleEvents();
  }

  void handleEvents();

  CommonBloc get commonBloc => _commonBloc;

  @mustCallSuper
  void init() {
    _commonBloc.init();
  }

  void showLoader() {
    _invalidateLoader(loading: true);
  }

  void hideLoader() {
    _invalidateLoader(loading: false);
  }

  void _invalidateLoader({
    bool loading = false,
  }) {
    _commonBloc.invalidateLoader(loading: loading);
  }

  void handleException(
    Exception exception,
  ) {
    _commonBloc.handleException(exception);
  }

  @override
  void onTransition(
    Transition<Event, State> transition,
  ) {
    logger
      ..d('Event: ${transition.event}')
      ..d('Current State: ${transition.currentState}')
      ..d('Next State ${transition.nextState}');
    super.onTransition(transition);
  }
}
