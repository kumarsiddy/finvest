import 'package:bondgrid/constants/config.dart';
import 'package:bondgrid/services/http_service.dart';

class AuthenticationRepo {
  BaseService baseService = BaseService();

  Future<Map<String, dynamic>> registerUser(String firstName, String middleName,
      String lastName, String email, String password,
      {String? referralCode}) async {
    final payload = {
      "firstName": firstName,
      "middleName": middleName,
      "lastName": lastName,
      "email": email.toLowerCase(),
      "password": password,
      if (referralCode != null) "referralCode": referralCode,
    };
    final response =
        await baseService.callPost(ConfigurationFile.register, payload);
    return response;
  }

  Future<Map<String, dynamic>> verifyEmailOTP(String otp) async {
    final response = await baseService
        .callPost(ConfigurationFile.verifyEmailOtp, {"otp": otp});
    return response;
  }

  Future<Map<String, dynamic>> generatePhoneOTP(String phoneNumber) async {
    final response = await baseService.callPost(
        ConfigurationFile.generatePhoneOTP, {"phoneNumber": phoneNumber});
    return response;
  }

  Future<Map<String, dynamic>> verifyPhoneOTP(String otp) async {
    final response = await baseService
        .callPost(ConfigurationFile.verifyPhoneOTP, {"otp": otp});
    return response;
  }

  Future<Map<String, dynamic>> resendOTP() async {
    final response =
        await baseService.callPost(ConfigurationFile.resendOTP, {});
    return response;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await baseService.callPost(ConfigurationFile.login,
        {"email": email.toLowerCase(), "password": password});
    return response;
  }

  Future<Map<String, dynamic>> verifyLoginOTP(String otp) async {
    final response = await baseService
        .callPost(ConfigurationFile.verifyLoginOTP, {"otp": otp});
    return response;
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await baseService.callPost(
        ConfigurationFile.forgotPassword, {"email": email.toLowerCase()});
    return response;
  }

  Future<Map<String, dynamic>> addPushNotificationToken(
      String pushNotificationToken) async {
    final response = await baseService.callPost(
        ConfigurationFile.addPushNotificationToken,
        {"pushNotificationToken": pushNotificationToken});
    return response;
  }

  Future<Map<String, dynamic>> addPushNotificationTokenAtRegistration(
      String pushNotificationToken) async {
    final response = await baseService.callPost(
        ConfigurationFile.addPushNotificationTokenAtRegistration,
        {"pushNotificationToken": pushNotificationToken});
    return response;
  }

  Future<Map<String, dynamic>> deletePushNotificationTokenAtSignout(
      String pushNotificationToken) async {
    final response = await baseService.callDelete(
        ConfigurationFile.deletePushNotificationTokenAtSignout,
        {"pushNotificationToken": pushNotificationToken});
    return response;
  }
}
