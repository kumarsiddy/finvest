import 'package:finvest/utils/string_keys.dart';
import 'package:dio/dio.dart';

class GenericException implements Exception {
  final String? message;

  GenericException({
    this.message,
  });
}

class ServerException implements GenericException {
  @override
  final String? message;

  ServerException({
    this.message,
  });
}

class UnknownServerException implements ServerException {
  @override
  final String message = StringKeys.pleaseTryAgain;

  static final _singleton = UnknownServerException._internal();

  factory UnknownServerException() {
    return _singleton;
  }

  UnknownServerException._internal();
}

ServerException handleApiException(dynamic error) {
  return ServerException(message: StringKeys.pleaseTryAgain);
  switch (error.runtimeType) {
    case DioError:
      // Here's the sample to get the failed response error code and message
      final res = (error as DioError).response;
      break;
    default:
      break;
  }
}
