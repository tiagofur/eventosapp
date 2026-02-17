import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('🚀 REQUEST:');
      print('  Method: ${options.method}');
      print('  URL: ${options.uri}');
      print('  Headers: ${options.headers}');
      print('  Data: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('✅ RESPONSE:');
      print('  URL: ${response.requestOptions.uri}');
      print('  Status: ${response.statusCode}');
      print('  Data: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('❌ ERROR:');
      print('  URL: ${err.requestOptions.uri}');
      print('  Type: ${err.type}');
      print('  Message: ${err.message}');
      print('  Response: ${err.response}');
    }
    handler.next(err);
  }
}
