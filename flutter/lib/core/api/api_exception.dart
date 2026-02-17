import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() {
    return 'ApiException: $message (statusCode: $statusCode)';
  }

  factory ApiException.fromDioError(DioException error) {
    String message;
    int? statusCode;
    dynamic data;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Tiempo de conexión agotado';
        break;
      case DioExceptionType.badResponse:
        statusCode = error.response?.statusCode;
        data = error.response?.data;
        message = _extractErrorMessage(error.response);
        break;
      case DioExceptionType.cancel:
        message = 'Petición cancelada';
        break;
      case DioExceptionType.connectionError:
        message = 'Error de conexión';
        break;
      case DioExceptionType.badCertificate:
        message = 'Error de certificado SSL';
        break;
      case DioExceptionType.unknown:
      default:
        message = error.message ?? 'Error desconocido';
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      data: data,
    );
  }

  static String _extractErrorMessage(dynamic response) {
    if (response?.data is Map<String, dynamic>) {
      final data = response!.data as Map<String, dynamic>;
      return data['error']?.toString() ?? data['message']?.toString() ?? 'Error en la respuesta del servidor';
    }
    return response?.data?.toString() ?? 'Error en la respuesta del servidor';
  }

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode != null && statusCode! >= 500;
}
