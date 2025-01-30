import 'package:bondgrid/enums/payment_method_status.dart';

class PaymentMethod {
  String? id;
  String? institutionName;
  String? accountName;
  String? accountMask;
  String? accountType;
  PaymentMethodStatus? status;

  PaymentMethod();

  PaymentMethod.fromParams(this.id, this.institutionName, this.accountName,
      this.accountMask, this.accountType, this.status);

  PaymentMethod.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    institutionName = json['institutionName'] ?? '';
    accountName = json['accountName'];
    accountMask = json['accountMask'];
    accountType = json['accountType'];

    status = json['status'] != null
        ? PaymentMethodStatus.values
            .firstWhere((element) => element.value == json['status'])
        : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'institutionName': institutionName,
      'accountName': accountName,
      'accountMask': accountMask,
      'accountType': accountType,
      'status': status?.value,
    };
  }
}
