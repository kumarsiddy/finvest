import 'package:bondgrid/bloc/home_bloc.dart';
import 'package:bondgrid/enums/notifications.dart';
import 'package:bondgrid/models/notification_preferences_list.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ListNotificationCategoriesScreen extends StatefulWidget {
  const ListNotificationCategoriesScreen(
      {super.key, required this.notificationType, required this.title});

  final NotificationType notificationType;
  final String title;

  @override
  State<ListNotificationCategoriesScreen> createState() =>
      _ListNotificationCategoriesScreenState();
}

class _ListNotificationCategoriesScreenState
    extends State<ListNotificationCategoriesScreen> {
  NotificationPreferencesList? _notificationPreferencesList;
  final Map<String, bool> _notificationStates = {};

  @override
  void initState() {
    super.initState();
    _loadPageData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadPageData() {
    context
        .read<HomeBloc>()
        .add(GetNotificationPreferencesEvent(widget.notificationType));
  }

  void _updatePreference(String notificationId, bool enabled) {
    // Add the logic to update the preference in your backend
    context
        .read<HomeBloc>()
        .add(UpdateNotificationPreferencesEvent(notificationId, enabled));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state.status == HomeStateStatus.failure) {
              FocusScope.of(context).unfocus();
              EasyLoading.showToast(state.errorMessage,
                  toastPosition: EasyLoadingToastPosition.bottom,
                  duration: const Duration(seconds: 5));
            }

            if (state is GetNotificationPreferencesListSuccessState) {
              _notificationPreferencesList = state.notificationPreferencesList;
              // Initialize _notificationStates based on the fetched preferences
              for (var pref
                  in _notificationPreferencesList!.notificationPreferences) {
                if (pref.category != null) {
                  _notificationStates[pref.category!] = pref.enabled ?? false;
                }
              }
            }

            if (state is UpdateNotificationPreferencesSuccessState) {
              if (state.notificationSetting.category != null &&
                  state.notificationSetting.enabled != null) {
                setState(() {
                  _notificationStates[state.notificationSetting.category!] =
                      state.notificationSetting.enabled!;
                });
              }
            }
          },
          child: Scaffold(
              appBar: AppBar(
                title: Text(
                  widget.title,
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
              body: _notificationPreferencesList != null
                  ? AbsorbPointer(
                      absorbing: state.status == HomeStateStatus.loading,
                      child: listNotificationSettings(context))
                  : const SizedBox.shrink()),
        );
      },
    );
  }

  Widget listNotificationSettings(BuildContext context) {
    return _notificationPreferencesList!.notificationPreferences.isEmpty
        ? Center(
            child: Text(
              "Nothing to show here",
              style: AppTheme.subBodyNormal,
            ),
          )
        : Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: SingleChildScrollView(
              child: Column(
                children: _notificationPreferencesList!.notificationPreferences
                    .map((notificationSetting) {
                  return (notificationSetting.category != null)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${notificationSetting.category}',
                                        style: AppTheme.bodyNormal,
                                      ),
                                      Text(
                                        '${notificationSetting.description}',
                                        style: AppTheme.subBodyNormal,
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _notificationStates[
                                          notificationSetting.category!] ??
                                      false,
                                  onChanged: notificationSetting.locked!
                                      ? null
                                      : (bool value) {
                                          _updatePreference(
                                              notificationSetting.id!, value);
                                          setState(() {
                                            _notificationStates[
                                                notificationSetting
                                                    .category!] = value;
                                          });
                                        },
                                  activeColor: AppTheme.primary,
                                  inactiveThumbColor:
                                      notificationSetting.locked!
                                          ? Colors.grey
                                          : null,
                                  inactiveTrackColor:
                                      notificationSetting.locked!
                                          ? Colors.grey
                                          : null,
                                ),
                              ],
                            ),
                            const Divider(),
                          ],
                        )
                      : const SizedBox.shrink();
                }).toList(),
              ),
            ),
          );
  }
}
