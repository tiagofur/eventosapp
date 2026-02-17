import 'package:eventosapp/core/api/api_client.dart';
import 'package:eventosapp/core/storage/secure_storage.dart';
import 'package:eventosapp/features/auth/data/models/auth_response_model.dart';
import 'package:eventosapp/features/auth/data/models/tokens_model.dart';
import 'package:eventosapp/features/auth/data/models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;

  AuthRepository({
    required ApiClient apiClient,
    required SecureStorage secureStorage,
  })  : _apiClient = apiClient,
        _secureStorage = secureStorage;

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final authResponse = AuthResponseModel.fromJson(response.data);

      await SecureStorage.saveTokens(
        accessToken: authResponse.tokens.accessToken,
        refreshToken: authResponse.tokens.refreshToken,
      );
      await SecureStorage.saveUserId(authResponse.user.id);

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/auth/register',
        data: {
          'email': email,
          'password': password,
          'name': name,
        },
      );

      final authResponse = AuthResponseModel.fromJson(response.data);

      await SecureStorage.saveTokens(
        accessToken: authResponse.tokens.accessToken,
        refreshToken: authResponse.tokens.refreshToken,
      );
      await SecureStorage.saveUserId(authResponse.user.id);

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await SecureStorage.clearTokens();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> forgotPassword({
    required String email,
  }) async {
    try {
      await _apiClient.post(
        '/api/auth/forgot-password',
        data: {
          'email': email,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponseModel?> getCurrentUser() async {
    final accessToken = await SecureStorage.getAccessToken();
    if (accessToken == null) return null;

    try {
      final response = await _apiClient.get('/api/auth/me');
      final user = UserModel.fromJson(response.data);

      await SecureStorage.saveUserId(user.id);
      return AuthResponseModel(
        user: user,
        tokens: TokensModel(accessToken: accessToken, refreshToken: '', expiresIn: 0),
      );
    } catch (e) {
      return null;
    }
  }
}
