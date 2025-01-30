import 'package:bondgrid/models/user_agreement.dart';

class UserAgreementList {
  List<UserAgreement> agreements = [];

  UserAgreementList();
  UserAgreementList.empty();

  UserAgreementList.fromJson(Map<String, dynamic> json) {
    dynamic list = json['elements'];
    for (var element in list) {
      agreements.add(UserAgreement.fromJson(element));
    }
  }
}
