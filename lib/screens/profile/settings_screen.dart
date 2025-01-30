import 'package:bondgrid/repo/home_repo.dart';
import 'package:bondgrid/screens/profile/notification_types.dart';
import 'package:bondgrid/screens/profile/security_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:bondgrid/bloc/home_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {},
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'Settings',
                style: AppTheme.profileText,
                textAlign: TextAlign.center,
              ),
              backgroundColor: AppTheme.backgroundColor,
              automaticallyImplyLeading: false,
              centerTitle: true,
              elevation: 0,
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.keyboard_arrow_left_rounded,
                  color: AppTheme.actionButton,
                  size: 22,
                ),
              ),
            ),
            body: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: ListView(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          Navigator.push(
                              context,
                              (Theme.of(context).platform == TargetPlatform.iOS)
                                  ? CupertinoPageRoute(
                                      builder: (context) => BlocProvider(
                                            create: (context) =>
                                                HomeBloc(HomeRepo()),
                                            child: const NotificationTypes(),
                                          ))
                                  : MaterialPageRoute(
                                      builder: (context) => BlocProvider(
                                            create: (context) =>
                                                HomeBloc(HomeRepo()),
                                            child: const NotificationTypes(),
                                          )));
                        },
                        child: Row(children: [
                          Expanded(
                              child: Text(
                            'Notifications',
                            style: AppTheme.bodyNormal,
                          )),
                          Icon(
                            Icons.keyboard_arrow_right_rounded,
                            size: 26,
                            color: Colors.grey[600]!.withOpacity(0.4),
                          ),
                        ])),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(),
                    const SizedBox(
                      height: 10,
                    ),
                    InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          Navigator.push(
                              context,
                              (Theme.of(context).platform == TargetPlatform.iOS)
                                  ? CupertinoPageRoute(
                                      builder: (context) => BlocProvider(
                                            create: (context) =>
                                                HomeBloc(HomeRepo()),
                                            child: const SecurityScreen(),
                                          ))
                                  : MaterialPageRoute(
                                      builder: (context) => BlocProvider(
                                            create: (context) =>
                                                HomeBloc(HomeRepo()),
                                            child: const SecurityScreen(),
                                          )));
                        },
                        child: Row(children: [
                          Expanded(
                              child: Text(
                            'Security',
                            style: AppTheme.bodyNormal,
                          )),
                          Icon(
                            Icons.keyboard_arrow_right_rounded,
                            size: 26,
                            color: Colors.grey[600]!.withOpacity(0.4),
                          ),
                        ])),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(),
                  ],
                )),
          ),
        );
      },
    );
  }
}
