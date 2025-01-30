import 'package:bondgrid/constants/config.dart';
import 'package:bondgrid/constants/error_codes.dart';
import 'package:bondgrid/models/api_exception.dart';
import 'package:bondgrid/services/http_service.dart';

class PlaidRepo {
  BaseService baseService = BaseService();

  Future<Map<String, dynamic>> getPlaidLinkToken(String platform) async {
    final payload = {"platform": platform};
    dynamic response = await baseService.callPost(
        ConfigurationFile.getPlaidLinkToken, payload);
    if (response.containsKey('data') && response['data'] != null) {
      return response['data'];
    } else {
      throw ApiException(
          ErrorCodes.INVALID_RESPONSE, "Response doesn't contain data");
    }
  }

  Future<Map<String, dynamic>> exchangePlaidPublicToken(
      Map<String, dynamic> linkData) async {
    final response = await baseService.callPost(
        ConfigurationFile.exchangePlaidPublicToken, linkData);
    return response;
  }
}
