import 'package:bondgrid/bloc/home_bloc.dart';
import 'package:bondgrid/repo/home_repo.dart';
import 'package:bondgrid/screens/home/home_screen.dart';
import 'package:bondgrid/screens/home/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreenBloc extends StatelessWidget {
  const HomeScreenBloc({
    Key? key,
    required this.navigatorKey,
    required this.showNavBar,
    required this.switchTab,
    required this.scrollController,
    this.showWelcomeScreen = false,
  }) : super(key: key);

  final GlobalKey<NavigatorState>? navigatorKey;
  final ValueNotifier<bool> showNavBar;
  final Function(int) switchTab;
  final ScrollController scrollController;
  final bool showWelcomeScreen;

  @override
  Widget build(BuildContext context) {
    if (showWelcomeScreen) {
      // Set showNavBar to false here
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showNavBar.value = false;
      });
    }

    return BlocProvider(
        create: (BuildContext context) => HomeBloc(HomeRepo()),
        child: showWelcomeScreen
            ? WelcomeScreen(showNavBar: showNavBar)
            : HomeScreen(
                showNavBar: showNavBar,
                switchTab: switchTab,
                scrollController: scrollController,
              ));
  }
}
