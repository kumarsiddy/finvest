import 'package:bondgrid/models/notification_setting.dart';

class NotificationPreferencesList {
  List<NotificationSetting> notificationPreferences = [];

  NotificationPreferencesList();

  NotificationPreferencesList.fromJson(Map<String, dynamic> json) {
    json.forEach((category, details) {
      notificationPreferences.add(
          NotificationSetting.fromJson({'category': category, ...details}));
    });

    // Sort the list alphabetically by category
    notificationPreferences.sort((a, b) {
      return a.category!.compareTo(b.category!);
    });
  }
}
