import 'dart:convert';

import 'package:bondgrid/constants/config.dart';
import 'package:bondgrid/constants/storage_constants.dart';
import 'package:bondgrid/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

class TokenService {
  static bool isJWTTokenExpired(String token) {
    // Split the token to extract the payload
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('Invalid token');
    }

    final payload = parts[1];
    final String payloadDecoded = B64urlEncRfc7515.decodeUtf8(payload);
    final Map<String, dynamic> payloadMap = json.decode(payloadDecoded);

    if (!payloadMap.containsKey('exp')) {
      return false; // If there's no expiration time, then it's not expired by this check.
    }

    final DateTime currentTime = DateTime.now();
    final DateTime expirationTime =
        DateTime.fromMillisecondsSinceEpoch(payloadMap['exp'] * 1000);
    return currentTime.isAfter(expirationTime);
  }

  static Future<String?> getJWTToken({bool forceRenew = false}) async {
    Map<String, dynamic>? tokenData =
        await StorageService.getItem(StorageConstants.jwtKey);
    if (tokenData == null) return null;
    if (!tokenData.containsKey('token')) return null;
    // Check if the token is expired. If yes, try to renew it.
    if (isJWTTokenExpired(tokenData['token']) || forceRenew) {
      Map<String, String> headers = {
        "Content-Type": "application/json; charset=UTF-8"
      };
      Response resp = await http
          .post(
            Uri.parse(ConfigurationFile.renewToken),
            headers: headers,
            body: jsonEncode({"token": tokenData['token']}),
          )
          .timeout(const Duration(seconds: 1000));
      if (resp.statusCode == 200) {
        final response = jsonDecode(resp.body);
        final token = await getTokenFromResponse(response);
        if (token != null) {
          await StorageService.storeItem(
              StorageConstants.jwtKey, {'token': token});
        }
        return token;
      }
      await StorageService.clearByKey(StorageConstants.jwtKey);
    } else {
      return tokenData['token'];
    }
    return null;
  }

  static Future<void> clearJWTKey() async {
    Map<String, dynamic>? tokenData =
        await StorageService.getItem(StorageConstants.jwtKey);
    if (tokenData == null) return;
    if (!tokenData.containsKey('token')) return;

    StorageService.clearByKey(StorageConstants.jwtKey);
  }

  static Future<String?> getTokenFromResponse(Map<String, dynamic> response) {
    if (response.containsKey('data') && response['data'] != null) {
      return Future.value(response['data']['token'] as String?);
    }
    return Future.value(null);
  }

  static bool hasValidVerificationStep(String token, String desiredStep) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('Invalid token');
    }

    final payload = parts[1];
    final String payloadDecoded = B64urlEncRfc7515.decodeUtf8(payload);
    final Map<String, dynamic> payloadMap = json.decode(payloadDecoded);

    if (!payloadMap.containsKey('verification_step')) {
      return false;
    }

    return payloadMap['verification_step'] == desiredStep;
  }
}
