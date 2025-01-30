import 'package:bondgrid/constants/config.dart';
import 'package:bondgrid/constants/error_codes.dart';
import 'package:bondgrid/models/api_exception.dart';
import 'package:bondgrid/models/cash_balance.dart';
import 'package:bondgrid/models/payment_method_list.dart';
import 'package:bondgrid/models/user_info.dart';
import 'package:bondgrid/services/http_service.dart';

class WalletRepo {
  BaseService baseService = BaseService();

  Future<UserInfo> getUserInformation() async {
    final response =
        await baseService.callGet(ConfigurationFile.getUserInformation);
    if (response.containsKey('data') && response['data'] != null) {
      return UserInfo.fromJson(response['data']);
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }

  Future<PaymentMethodList> getPaymentMethods() async {
    dynamic response =
        await baseService.callGet(ConfigurationFile.getPaymentMethods);
    if (response.containsKey('data') && response['data'] != null) {
      return PaymentMethodList.fromJson(response['data']);
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }

  Future<Map<String, dynamic>> deletePaymentMethod(
      String paymentMethodId) async {
    Map<String, dynamic> payload = {"paymentMethodId": paymentMethodId};
    final response = await baseService.callDelete(
        ConfigurationFile.deletePaymentMethod, payload);
    return response;
  }

  Future<CashBalance> getPortfolioValue() async {
    dynamic response =
        await baseService.callGet(ConfigurationFile.getPortfolioValue);
    if (response.containsKey('data') && response['data'] != null) {
      return CashBalance.fromJson(response['data']);
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }
}
