import 'package:dio/dio.dart';
import '../../storage/secure_storage.dart';
import 'package:eventosapp/config/api_config.dart';

class RefreshTokenInterceptor extends Interceptor {
  final Dio _dio;

  RefreshTokenInterceptor(this._dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        final refreshToken = await SecureStorage.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          return handler.next(err);
        }

        final response = await _dio.post(
          '${ApiConfig.baseUrl}/api/auth/refresh',
          data: {'refresh_token': refreshToken},
        );

        if (response.statusCode == 200) {
          final newAccessToken = response.data['access_token'];
          final newRefreshToken = response.data['refresh_token'];

          await SecureStorage.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );

          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newAccessToken';

          final cloneReq = await _dio.fetch(opts);
          return handler.resolve(cloneReq);
        }
      } catch (e) {
        await SecureStorage.clearTokens();
      }
    }
    handler.next(err);
  }
}
