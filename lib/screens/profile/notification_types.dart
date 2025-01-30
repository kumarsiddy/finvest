import 'package:bondgrid/enums/notifications.dart';
import 'package:bondgrid/repo/home_repo.dart';
import 'package:bondgrid/screens/profile/list_notification_categories.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:bondgrid/bloc/home_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationTypes extends StatefulWidget {
  const NotificationTypes({super.key});

  @override
  State<NotificationTypes> createState() => _NotificationTypesState();
}

class _NotificationTypesState extends State<NotificationTypes> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {},
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'Notifications',
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
                                            child:
                                                const ListNotificationCategoriesScreen(
                                                    notificationType:
                                                        NotificationType.PUSH,
                                                    title:
                                                        'Push Notifications'),
                                          ))
                                  : MaterialPageRoute(
                                      builder: (context) => BlocProvider(
                                            create: (context) =>
                                                HomeBloc(HomeRepo()),
                                            child:
                                                const ListNotificationCategoriesScreen(
                                                    notificationType:
                                                        NotificationType.PUSH,
                                                    title:
                                                        'Push Notifications'),
                                          )));
                        },
                        child: Row(children: [
                          Expanded(
                              child: Text(
                            'Push Notifications',
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
                                            child:
                                                const ListNotificationCategoriesScreen(
                                                    notificationType:
                                                        NotificationType.EMAIL,
                                                    title:
                                                        'Email Notifications'),
                                          ))
                                  : MaterialPageRoute(
                                      builder: (context) => BlocProvider(
                                            create: (context) =>
                                                HomeBloc(HomeRepo()),
                                            child:
                                                const ListNotificationCategoriesScreen(
                                                    notificationType:
                                                        NotificationType.EMAIL,
                                                    title:
                                                        'Email Notifications'),
                                          )));
                        },
                        child: Row(children: [
                          Expanded(
                              child: Text(
                            'Email Notifications',
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
