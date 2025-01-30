import 'package:bondgrid/constants/config.dart';
import 'package:bondgrid/constants/error_codes.dart';
import 'package:bondgrid/models/api_exception.dart';
import 'package:bondgrid/models/asset_list.dart';
import 'package:bondgrid/models/cash_balance.dart';
import 'package:bondgrid/models/payment_method_list.dart';
import 'package:bondgrid/models/purchase_response.dart';
import 'package:bondgrid/models/user_info.dart';
import 'package:bondgrid/services/http_service.dart';

class TradingRepo {
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

  Future<AssetList> getAssetList() async {
    final response = await baseService.callGet(ConfigurationFile.listAssets);
    if (response.containsKey('data') && response['data'] != null) {
      return AssetList.fromJson(response['data']);
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

  Future<PurchaseResponse> createPurchaseTrade(
      String amount,
      String cusip,
      String fundSourceType,
      String paymentMethodId,
      String duration,
      bool autoRoll) async {
    Map<String, dynamic> payload = {
      "amount": amount,
      "cusip": cusip,
      "fundSourceType": fundSourceType,
      "paymentMethodId": paymentMethodId,
      "duration": duration,
      "autoRoll": autoRoll
    };
    final response = await baseService.callPost(
        ConfigurationFile.purchaseTreasuryBill, payload);
    if (response.containsKey('data') && response['data'] != null) {
      return PurchaseResponse.fromJson(response['data']);
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }

  Future<CashBalance> getOnlyBuyingPower() async {
    dynamic response =
        await baseService.callGet(ConfigurationFile.getOnlyBuyingPower);
    if (response.containsKey('data') && response['data'] != null) {
      return CashBalance.fromJson(response['data']);
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }
}
