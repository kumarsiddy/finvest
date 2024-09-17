import 'dart:math' as math;

import 'package:finvest/infrastructure/api_services/logger.dart';
import 'package:dio/dio.dart';

final loggerInterceptor = LoggerInterceptor(
  requestHeader: true,
  requestBody: true,
  responseHeader: true,
);

class LoggerInterceptor extends Interceptor {
  /// Print request [Options]
  final bool request;

  /// Print request header [Options.headers]
  final bool requestHeader;

  /// Print request data [Options.rocket]
  final bool requestBody;

  /// Print [Response.data]
  final bool responseBody;

  /// Print [Response.headers]
  final bool responseHeader;

  /// Print error message
  final bool error;

  /// InitialTab count to logPrint json response
  static const int initialTab = 1;

  /// 1 tab length
  static const String tabStep = '    ';

  /// Print compact json response
  final bool compact;

  /// Width size per logPrint
  final int maxWidth;

  /// Log printer; defaults logPrint log to console.
  /// In flutter, you'd better use debugPrint.
  /// you can also write log in a file.
  void Function(Object object) logPrint;

  LoggerInterceptor({
    this.request = true,
    this.requestHeader = false,
    this.requestBody = false,
    this.responseHeader = false,
    this.responseBody = true,
    this.error = true,
    this.maxWidth = 90,
    this.compact = true,
    this.logPrint = print,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logPrint = logger.d;
    if (request) {
      _printRequestHeader(options, loggerFunc: logPrint);
    }
    if (requestHeader) {
      _printMapAsTable(
        options.queryParameters,
        header: 'Query Parameters',
        loggerFunc: logPrint,
      );
      final requestHeaders = <String, dynamic>{}..addAll(options.headers);
      requestHeaders['contentType'] = options.contentType?.toString();
      requestHeaders['responseType'] = options.responseType.toString();
      requestHeaders['followRedirects'] = options.followRedirects;
      requestHeaders['connectTimeout'] = options.connectTimeout;
      requestHeaders['receiveTimeout'] = options.receiveTimeout;
      _printMapAsTable(requestHeaders, header: 'Headers', loggerFunc: logPrint);
      _printMapAsTable(options.extra, header: 'Extras', loggerFunc: logPrint);
    }
    if (requestBody && options.method != 'GET') {
      final dynamic data = options.data;
      if (data != null) {
        if (data is Map) {
          _printMapAsTable(
            options.data as Map?,
            header: 'Body',
            loggerFunc: logPrint,
          );
        }
        if (data is FormData) {
          final formDataMap = <String, dynamic>{}
            ..addEntries(data.fields)
            ..addEntries(data.files);
          _printMapAsTable(formDataMap,
              header: 'Form data | ${data.boundary}', loggerFunc: logPrint);
        } else {
          _printBlock(data.toString(), loggerFunc: logPrint);
        }
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    logPrint = logger.e;
    if (error) {
      if (err.type == DioErrorType.badResponse) {
        final uri = err.response?.requestOptions.uri;
        _printBoxed(
          header:
              'DioError ║ Status: ${err.response?.statusCode} ${err.response?.statusMessage}',
          text: uri.toString(),
          loggerFunc: logger.e,
        );
        if (err.response != null && err.response?.data != null) {
          logPrint('╔ ${err.type}');
          _printResponse(err.response!, loggerFunc: logger.e);
        }
        _printLine(logPrint, '╚');
        logPrint('');
      } else {
        _printBoxed(
          header: 'DioError ║ ${err.type}',
          text: err.message,
          loggerFunc: logger.e,
        );
      }
    }
    super.onError(err, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logPrint = logger.i;
    _printResponseHeader(response, loggerFunc: logPrint);
    if (responseHeader) {
      final responseHeaders = <String, String>{};
      response.headers
          .forEach((k, list) => responseHeaders[k] = list.toString());
      _printMapAsTable(
        responseHeaders,
        header: 'Headers',
        loggerFunc: logPrint,
      );
    }

    if (responseBody) {
      logPrint('╔ Body');
      logPrint('║');
      _printResponse(response, loggerFunc: logger.i);
      logPrint('║');
      _printLine(logPrint, '╚');
    }
    super.onResponse(response, handler);
  }

  void _printBoxed({
    String? header,
    String? text,
    required Function(Object object) loggerFunc,
  }) {
    logPrint = loggerFunc;
    logPrint('');
    logPrint('╔╣ $header');
    logPrint('║  $text');
    _printLine(
      logPrint,
      '╚',
    );
  }

  void _printResponse(
    Response response, {
    required Function(Object object) loggerFunc,
  }) {
    logPrint = loggerFunc;
    if (response.data != null) {
      if (response.data is Map) {
        _printPrettyMap(response.data as Map, loggerFunc: logPrint);
      } else if (response.data is List) {
        logPrint('║${_indent()}[');
        _printList(response.data as List, loggerFunc: logPrint);
        logPrint('║${_indent()}[');
      } else {
        _printBlock(response.data.toString(), loggerFunc: logPrint);
      }
    }
  }

  void _printResponseHeader(
    Response response, {
    required Function(Object object) loggerFunc,
  }) {
    logPrint = loggerFunc;
    final uri = response.requestOptions.uri;
    final method = response.requestOptions.method;
    _printBoxed(
      header:
          'Response ║ $method ║ Status: ${response.statusCode} ${response.statusMessage}',
      text: uri.toString(),
      loggerFunc: logPrint,
    );
  }

  void _printRequestHeader(
    RequestOptions options, {
    required Function(Object object) loggerFunc,
  }) {
    final uri = options.uri;
    final method = options.method;
    _printBoxed(
      header: 'Request ║ $method ',
      text: uri.toString(),
      loggerFunc: loggerFunc,
    );
  }

  void _printLine(
    Function(Object object) loggerFunc, [
    String pre = '',
    String suf = '╝',
  ]) {
    logPrint = loggerFunc;
    logPrint('$pre${'═' * maxWidth}$suf');
  }

  void _printKV(
    String? key,
    Object? v, {
    required Function(Object object) loggerFunc,
  }) {
    logPrint = loggerFunc;
    final pre = '╟ $key: ';
    final msg = v.toString();

    if (pre.length + msg.length > maxWidth) {
      logPrint(pre);
      _printBlock(msg, loggerFunc: logPrint);
    } else {
      logPrint('$pre$msg');
    }
  }

  void _printBlock(
    String msg, {
    required Function(Object object) loggerFunc,
  }) {
    logPrint = loggerFunc;
    final lines = (msg.length / maxWidth).ceil();
    for (var i = 0; i < lines; ++i) {
      logPrint(
        (i >= 0 ? '║ ' : '') +
            msg.substring(
              i * maxWidth,
              math.min<int>(
                i * maxWidth + maxWidth,
                msg.length,
              ),
            ),
      );
    }
  }

  String _indent([int tabCount = initialTab]) => tabStep * tabCount;

  void _printPrettyMap(
    Map data, {
    int tabs = initialTab,
    bool isListItem = false,
    bool isLast = false,
    required Function(Object object) loggerFunc,
  }) {
    logPrint = loggerFunc;
    var _tabs = tabs;
    final isRoot = _tabs == initialTab;
    final initialIndent = _indent(_tabs);
    _tabs++;

    if (isRoot || isListItem) logPrint('║$initialIndent{');

    data.keys.toList().asMap().forEach((index, dynamic key) {
      final isLast = index == data.length - 1;
      dynamic value = data[key];
      if (value is String) {
        value = '"${value.toString().replaceAll(RegExp(r'(\r|\n)+'), " ")}"';
      }
      if (value is Map) {
        if (compact && _canFlattenMap(value)) {
          logPrint('║${_indent(_tabs)} $key: $value${!isLast ? ',' : ''}');
        } else {
          logPrint('║${_indent(_tabs)} $key: {');
          _printPrettyMap(value, tabs: _tabs, loggerFunc: logPrint);
        }
      } else if (value is List) {
        if (compact && _canFlattenList(value)) {
          logPrint('║${_indent(_tabs)} $key: ${value.toString()}');
        } else {
          logPrint('║${_indent(_tabs)} $key: [');
          _printList(value, tabs: _tabs, loggerFunc: logPrint);
          logPrint('║${_indent(_tabs)} ]${isLast ? '' : ','}');
        }
      } else {
        final msg = value.toString().replaceAll('\n', '');
        final indent = _indent(_tabs);
        final linWidth = maxWidth - indent.length;
        if (msg.length + indent.length > linWidth) {
          final lines = (msg.length / linWidth).ceil();
          for (var i = 0; i < lines; ++i) {
            logPrint(
                '║${_indent(_tabs)} ${msg.substring(i * linWidth, math.min<int>(i * linWidth + linWidth, msg.length))}');
          }
        } else {
          logPrint('║${_indent(_tabs)} $key: $msg${!isLast ? ',' : ''}');
        }
      }
    });

    logPrint('║$initialIndent}${isListItem && !isLast ? ',' : ''}');
  }

  void _printList(
    List list, {
    int tabs = initialTab,
    required Function(Object object) loggerFunc,
  }) {
    logPrint = loggerFunc;
    list.asMap().forEach((i, dynamic e) {
      final isLast = i == list.length - 1;
      if (e is Map) {
        if (compact && _canFlattenMap(e)) {
          logPrint('║${_indent(tabs)}  $e${!isLast ? ',' : ''}');
        } else {
          _printPrettyMap(
            e,
            tabs: tabs + 1,
            isListItem: true,
            isLast: isLast,
            loggerFunc: logPrint,
          );
        }
      } else {
        logPrint('║${_indent(tabs + 2)} $e${isLast ? '' : ','}');
      }
    });
  }

  bool _canFlattenMap(Map map) {
    return map.values
            .where((dynamic val) => val is Map || val is List)
            .isEmpty &&
        map.toString().length < maxWidth;
  }

  bool _canFlattenList(List list) {
    return list.length < 10 && list.toString().length < maxWidth;
  }

  void _printMapAsTable(
    Map? map, {
    String? header,
    required Function(Object object) loggerFunc,
  }) {
    logPrint = loggerFunc;
    if (map == null || map.isEmpty) return;
    logPrint('╔ $header ');
    map.forEach(
      (dynamic key, dynamic value) => _printKV(
        key.toString(),
        value,
        loggerFunc: loggerFunc,
      ),
    );
    _printLine(
      logPrint,
      '╚',
    );
  }
}
