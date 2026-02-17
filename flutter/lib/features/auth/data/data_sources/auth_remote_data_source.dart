import 'package:eventosapp/core/api/api_client.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/api/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _apiClient.post(
      '/api/auth/register',
      data: {
        'email': email,
        'password': password,
        'name': name,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await _apiClient.post(
      '/api/auth/refresh',
      data: {
        'refresh_token': refreshToken,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _apiClient.get('/api/auth/me');
    return response.data as Map<String, dynamic>;
  }

  Future<void> forgotPassword({
    required String email,
  }) async {
    await _apiClient.post(
      '/api/auth/forgot-password',
      data: {
        'email': email,
      },
    );
  }
}
