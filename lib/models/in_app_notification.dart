import 'package:bondgrid/enums/button_link_type.dart';
import 'package:bondgrid/enums/in_app_notification_display_type.dart';
import 'package:bondgrid/enums/in_app_notification_status.dart';
import 'package:bondgrid/enums/in_app_notification_type.dart';
import 'package:flutter/material.dart';

class InAppNotification {
  String? id;
  String? userId;
  InAppNotificationType? type;
  InAppNotificationDisplayType? displayType;
  InAppNotificationStatus? status;
  DateTime? startDate;
  DateTime? endDate;
  String? minAndroidAppVersion;
  String? miniOSAppVersion;
  DateTime? createdAt;
  DateTime? updatedAt;

  // Associated content details
  String? title;
  String? body;
  String? buttonLink;
  ButtonLinkType? buttonLinkType;
  String? buttonText;
  String? imageUrl;
  String? localImagePath;
  Color? backgroundColor;
  Color? textColor;

  InAppNotification();

  InAppNotification.fromParams(
      {this.id,
      this.userId,
      this.type,
      this.displayType,
      this.status,
      this.startDate,
      this.endDate,
      this.minAndroidAppVersion,
      this.miniOSAppVersion,
      this.createdAt,
      this.updatedAt,
      this.title,
      this.body,
      this.buttonLink,
      this.buttonLinkType,
      this.buttonText,
      this.imageUrl,
      this.localImagePath,
      this.backgroundColor,
      this.textColor});

  InAppNotification.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    type = json['type'] != null
        ? InAppNotificationType.values
            .firstWhere((e) => e.value == json['type'])
        : null;
    displayType = json['displayType'] != null
        ? InAppNotificationDisplayType.values
            .firstWhere((e) => e.value == json['displayType'])
        : null;
    status = json['status'] != null
        ? InAppNotificationStatus.values
            .firstWhere((e) => e.value == json['status'])
        : null;
    startDate =
        json['startDate'] != null ? DateTime.parse(json['startDate']) : null;
    endDate = json['endDate'] != null ? DateTime.parse(json['endDate']) : null;
    minAndroidAppVersion = json['minAndroidAppVersion'];
    miniOSAppVersion = json['miniOSAppVersion'];
    createdAt =
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
    updatedAt =
        json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null;
    // Assume defaultInAppNotification is nested within the notification JSON
    var content = json['defaultInAppNotification'];
    if (content != null) {
      title = content['title'];
      body = content['body'];
      buttonLink = content['buttonLink'];
      buttonLinkType = content['buttonLinkType'] != null
          ? ButtonLinkType.values
              .firstWhere((e) => e.value == content['buttonLinkType'])
          : null;
      buttonText = content['buttonText'];
      imageUrl = content['imageUrl'];
      localImagePath = content['localImagePath'];
      backgroundColor = content['backgroundColor'] != null
          ? parseColor(content['backgroundColor'])
          : null;
      textColor = content['textColor'] != null
          ? parseColor(content['textColor'])
          : null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['userId'] = userId;
    data['type'] = type;
    data['displayType'] = displayType;
    data['status'] = status;
    data['startDate'] = startDate?.toIso8601String();
    data['endDate'] = endDate?.toIso8601String();
    data['minAndroidAppVersion'] = minAndroidAppVersion;
    data['miniOSAppVersion'] = miniOSAppVersion;
    data['createdAt'] = createdAt?.toIso8601String();
    data['updatedAt'] = updatedAt?.toIso8601String();

    data['title'] = title;
    data['body'] = body;
    data['buttonLink'] = buttonLink;
    data['buttonLinkType'] = buttonLinkType;
    data['buttonText'] = buttonText;
    data['imageUrl'] = imageUrl;
    data['localImagePath'] = localImagePath;
    data['backgroundColor'] = backgroundColor;
    data['textColor'] = textColor;

    return data;
  }

  // Function to parse color from a hex code string
  Color parseColor(String hexCode) {
    // Remove the "#" at the start of the string
    hexCode = hexCode.replaceAll('#', '');

    // Check if the string is of valid length and add 'FF' for opacity if needed
    if (hexCode.length == 6) {
      hexCode = 'FF$hexCode';
    }

    if (hexCode.length != 8) {
      return Colors.transparent;
    }

    // Convert the hex code to a Color
    return Color(int.parse('0x$hexCode'));
  }
}
