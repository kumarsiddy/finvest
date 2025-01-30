import 'dart:convert';
import 'dart:typed_data';

import 'package:bondgrid/constants/error_message.dart';
import 'package:bondgrid/models/api_exception.dart';
import 'package:bondgrid/services/token_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class BaseService {
  Future<dynamic> callPost(String url, Map<String, dynamic> body) async {
    String? jwtToken = await TokenService.getJWTToken();
    Map<String, String> headers = {
      "Content-Type": "application/json; charset=UTF-8",
      if (jwtToken != null) "Authorization": "Bearer $jwtToken"
    };

    Response resp = await http
        .post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 1000));

    if (resp.statusCode != 200) {
      final Map<String, dynamic> errorResponse = jsonDecode(resp.body);
      final String errorCode = errorResponse['errorCode'] ?? '';
      final String errorMessage =
          errorResponse['errorMessage'] ?? ErrorMessage.unexpectedErrorMessage;

      print(errorResponse);
      throw ApiException(errorCode, errorMessage);
    }

    print(jsonDecode(resp.body));
    return jsonDecode(resp.body);
  }

  Future<dynamic> callPut(String url, Map<String, dynamic> body) async {
    String? jwtToken = await TokenService.getJWTToken();
    Map<String, String> headers = {
      "Content-Type": "application/json; charset=UTF-8",
      if (jwtToken != null) "Authorization": "Bearer $jwtToken"
    };

    Response resp = await http
        .put(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 1000));

    if (resp.statusCode != 200) {
      final Map<String, dynamic> errorResponse = jsonDecode(resp.body);
      final String errorCode = errorResponse['errorCode'] ?? '';
      final String errorMessage =
          errorResponse['errorMessage'] ?? ErrorMessage.unexpectedErrorMessage;

      print(errorResponse);
      throw ApiException(errorCode, errorMessage);
    }

    print(jsonDecode(resp.body));
    return jsonDecode(resp.body);
  }

  Future<dynamic> callGet(String url,
      {Map<String, String>? queryParams}) async {
    String? jwtToken = await TokenService.getJWTToken();
    Map<String, String> headers = {
      "Content-Type": "application/json; charset=UTF-8",
      if (jwtToken != null) "Authorization": "Bearer $jwtToken"
    };

    Uri uri = Uri.parse(url);
    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams);
    }

    Response resp = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 1000));

    if (resp.statusCode != 200) {
      final Map<String, dynamic> errorResponse = jsonDecode(resp.body);
      final String errorCode = errorResponse['errorCode'] ?? '';
      final String errorMessage =
          errorResponse['errorMessage'] ?? ErrorMessage.unexpectedErrorMessage;

      print(errorResponse);
      throw ApiException(errorCode, errorMessage);
    }

    print(jsonDecode(resp.body));
    return jsonDecode(resp.body);
  }

  Future<Uint8List> callGetPdf(String url,
      {Map<String, String>? queryParams}) async {
    String? jwtToken = await TokenService.getJWTToken();
    Map<String, String> headers = {
      if (jwtToken != null) "Authorization": "Bearer $jwtToken"
    };

    Uri uri = Uri.parse(url);
    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams);
    }

    final resp = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 1000));

    if (resp.statusCode != 200) {
      final Map<String, dynamic> errorResponse = jsonDecode(resp.body);
      final String errorCode = errorResponse['errorCode'] ?? '';
      final String errorMessage =
          errorResponse['errorMessage'] ?? ErrorMessage.unexpectedErrorMessage;

      print(errorResponse);
      throw ApiException(errorCode, errorMessage);
    }

    return resp.bodyBytes;
  }

  Future<dynamic> callDelete(String url, Map<String, dynamic> body) async {
    String? jwtToken = await TokenService.getJWTToken();
    Map<String, String> headers = {
      "Content-Type": "application/json; charset=UTF-8",
      if (jwtToken != null) "Authorization": "Bearer $jwtToken"
    };

    Response resp = await http
        .delete(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 1000));

    if (resp.statusCode != 200) {
      final Map<String, dynamic> errorResponse = jsonDecode(resp.body);
      final String errorCode = errorResponse['errorCode'] ?? '';
      final String errorMessage =
          errorResponse['errorMessage'] ?? ErrorMessage.unexpectedErrorMessage;

      print(errorResponse);
      throw ApiException(errorCode, errorMessage);
    }

    print(jsonDecode(resp.body));
    return jsonDecode(resp.body);
  }
}
