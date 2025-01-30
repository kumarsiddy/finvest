import 'package:bondgrid/bloc/trading_bloc.dart';
import 'package:bondgrid/repo/trading_repo.dart';
import 'package:bondgrid/screens/trading/trading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TradingScreenBloc extends StatelessWidget {
  const TradingScreenBloc(
      {Key? key,
      required this.navigatorKey,
      required this.showNavBar,
      required this.scrollController})
      : super(key: key);

  final GlobalKey<NavigatorState>? navigatorKey;
  final ValueNotifier<bool> showNavBar;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) => TradingBloc(TradingRepo()),
        child: TradingScreen(
          showNavBar: showNavBar,
          scrollController: scrollController,
        ));
  }
}
