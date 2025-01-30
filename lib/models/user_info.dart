import 'package:bondgrid/models/employment_information.dart';
import 'package:bondgrid/models/financial_profile.dart';
import 'package:bondgrid/models/payment_method.dart';
import 'package:bondgrid/models/personal_details.dart';
import 'package:bondgrid/models/user_verification.dart';

class UserInfo {
  UserVerification verification = UserVerification();
  PersonalDetails personalDetails = PersonalDetails();
  EmploymentInformation employmentInformation = EmploymentInformation();
  FinancialProfile financialProfile = FinancialProfile();
  List<PaymentMethod>? paymentsDetails;

  UserInfo();

  UserInfo.fromJson(Map<String, dynamic> json) {
    verification = UserVerification.fromJson(json['verification']);
    personalDetails = PersonalDetails.fromJson(json['personalDetails']);
    employmentInformation =
        EmploymentInformation.fromJson(json['employmentInformation']);
    financialProfile = FinancialProfile.fromJson(json['financialProfile']);
    paymentsDetails = _paymentListFromJson(json['paymentsDetails']);
  }

  List<PaymentMethod> _paymentListFromJson(List<dynamic>? jsonList) {
    return jsonList?.map((item) => PaymentMethod.fromJson(item)).toList() ?? [];
  }

  Map<String, dynamic> toJson() {
    return {
      'verification': verification.toJson(),
      'personalDetails': personalDetails.toJson(),
      'employmentInformation': employmentInformation.toJson(),
      'financialProfile': financialProfile.toJson(),
      'paymentsDetails':
          paymentsDetails?.map((payment) => payment.toJson()).toList(),
    };
  }
}
