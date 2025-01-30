class NotificationSetting {
  String? id;
  String? category;
  bool? enabled;
  bool? locked;
  String? description;

  NotificationSetting();

  NotificationSetting.fromParams(
      this.id, this.category, this.enabled, this.locked, this.description);

  NotificationSetting.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    category = json['category'];
    enabled = json['enabled'];
    locked = json['locked'];
    description = json['description'];
  }
}
