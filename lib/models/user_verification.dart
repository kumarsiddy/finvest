import 'package:bondgrid/enums/verification_status.dart';

class UserVerification {
  VerificationStatus? status;
  List<String>? failedAttributes;
  String? completionLink;
  String? failureMessage;
  bool? customFailureInput;

  UserVerification();

  UserVerification.fromParams(this.status, this.failedAttributes,
      this.completionLink, this.failureMessage, this.customFailureInput);

  UserVerification.fromJson(Map<String, dynamic> json) {
    status = json['status'] != null
        ? VerificationStatus.values
            .firstWhere((element) => element.value == json['status'])
        : null;
    failedAttributes = _stringListFromJson(json['failedAttributes']);
    completionLink = json['completionLink'];
    failureMessage = json['failureMessage'];
    customFailureInput = json['customFailureInput'];
  }

  List<String> _stringListFromJson(List<dynamic>? jsonList) {
    return jsonList?.map((item) => item.toString()).toList() ?? [];
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status?.value,
      'failedAttributes': failedAttributes,
      'completionLink': completionLink,
      'failureMessage': failureMessage,
      'customFailureInput': customFailureInput
    };
  }
}
