import 'package:bondgrid/enums/in_app_notification_display_type.dart';
import 'package:bondgrid/models/in_app_notification.dart';

class InAppNotificationList {
  List<InAppNotification> notifications = [];
  List<InAppNotification> cardNotifications = [];
  List<InAppNotification> modalNotifications = [];

  InAppNotificationList();
  InAppNotificationList.empty();

  InAppNotificationList.fromJson(Map<String, dynamic> json) {
    dynamic list = json['elements'];
    for (var element in list) {
      InAppNotification notification = InAppNotification.fromJson(element);
      notifications.add(notification);

      // Categorize notification based on its display type
      if (notification.displayType == InAppNotificationDisplayType.CARD) {
        cardNotifications.add(notification);
      } else if (notification.displayType ==
          InAppNotificationDisplayType.MODAL) {
        modalNotifications.add(notification);
      }
    }

    // Sort the notifications by time in descending order
    notifications.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    cardNotifications.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    modalNotifications.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> jsonList =
        notifications.map((notification) => notification.toJson()).toList();

    return {
      'elements': jsonList,
    };
  }
}
