import 'package:bondgrid/bloc/home_bloc.dart';
import 'package:bondgrid/repo/home_repo.dart';
import 'package:bondgrid/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreenBloc extends StatelessWidget {
  const ProfileScreenBloc(
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
        create: (BuildContext context) => HomeBloc(HomeRepo()),
        child: ProfileScreen(
          showNavBar: showNavBar,
          scrollController: scrollController,
        ));
  }
}
