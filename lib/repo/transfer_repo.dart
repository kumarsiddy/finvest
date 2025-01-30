import 'package:bondgrid/constants/config.dart';
import 'package:bondgrid/constants/error_codes.dart';
import 'package:bondgrid/models/api_exception.dart';
import 'package:bondgrid/models/cash_balance.dart';
import 'package:bondgrid/models/payment_method_list.dart';
import 'package:bondgrid/models/transaction.dart';
import 'package:bondgrid/services/http_service.dart';

class TransferRepo {
  BaseService baseService = BaseService();

  Future<Transaction> createDeposit(
      String amount, String paymentMethodId) async {
    Map<String, dynamic> payload = {
      "amount": amount,
      "paymentMethodId": paymentMethodId
    };
    final response =
        await baseService.callPost(ConfigurationFile.createDeposit, payload);
    if (response.containsKey('data') && response['data'] != null) {
      return Transaction.fromJson(response['data']);
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }

  Future<Transaction> createWithdrawal(
      String amount, String paymentMethodId) async {
    Map<String, dynamic> payload = {
      "amount": amount,
      "paymentMethodId": paymentMethodId
    };
    final response =
        await baseService.callPost(ConfigurationFile.createWithdrawal, payload);
    if (response.containsKey('data') && response['data'] != null) {
      return Transaction.fromJson(response['data']);
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

  Future<CashBalance> getCashBalance() async {
    dynamic response =
        await baseService.callGet(ConfigurationFile.getBuyingPower);
    if (response.containsKey('data') && response['data'] != null) {
      return CashBalance.fromJson(response['data']);
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }
}
