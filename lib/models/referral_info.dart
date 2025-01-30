import 'package:bondgrid/models/referral.dart';

class ReferralInfo {
  List<Referral> referralList = [];
  String? activatedDate;
  String? numberOfReferrals;
  String? bonusMonths;
  String? referralCode;
  String? referralBonus;
  String? interestRate;
  String? startDate;
  String? endDate;
  String? daysLeft;
  String? totalBonusAmount;
  String? totalRealizedBonusAmount;
  String? selfReferralStatus;

  ReferralInfo();

  ReferralInfo.fromJson(Map<String, dynamic> json) {
    dynamic list = json['referralList'];
    for (var element in list) {
      referralList.add(Referral.fromJson(element));
    }
    activatedDate = json['activatedDate'];
    numberOfReferrals = json['numberOfReferrals']?.toString();
    bonusMonths = json['bonusMonths']?.toString();
    referralCode = json['referralCode'];
    referralBonus = json['referralBonusValue']?.toString();
    interestRate = json['displayedInterestRate']?.toString();
    startDate = json['startDate'];
    endDate = json['endDate'];
    daysLeft = json['daysLeft']?.toString();
    totalBonusAmount = json['totalBonusAmount']?.toString();
    totalRealizedBonusAmount = json['totalRealizedBonusAmount']?.toString();
    selfReferralStatus = json['selfReferralStatus'];
  }
}
