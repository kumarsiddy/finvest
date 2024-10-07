import 'package:finvest/presentation/application/base/base_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension ContextX on BuildContext {
  B bloc<B extends BaseBloc>() {
    return BlocProvider.of<B>(this);
  }

  S state<B extends BaseBloc, S extends CommonState>() {
    return BlocProvider.of<B>(this).state as S;
  }

  void started<T extends BaseBloc>() {
    BlocProvider.of<T>(this).init();
  }
}
