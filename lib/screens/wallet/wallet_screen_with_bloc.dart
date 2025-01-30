import 'package:bondgrid/bloc/wallet_bloc.dart';
import 'package:bondgrid/repo/wallet_repo.dart';
import 'package:bondgrid/screens/wallet/wallet_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletScreenBloc extends StatelessWidget {
  const WalletScreenBloc(
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
        create: (BuildContext context) => WalletBloc(WalletRepo()),
        child: WalletScreen(
          showNavBar: showNavBar,
          scrollController: scrollController,
        ));
  }
}
