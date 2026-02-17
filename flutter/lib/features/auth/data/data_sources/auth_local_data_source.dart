import 'package:hive/hive.dart';

class AuthLocalDataSource {
  final Box _box;

  AuthLocalDataSource(this._box);

  Future<String?> getAccessToken() async {
    return _box.get('access_token');
  }

  Future<String?> getRefreshToken() async {
    return _box.get('refresh_token');
  }

  Future<String?> getUserId() async {
    return _box.get('user_id');
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _box.put('access_token', accessToken);
    await _box.put('refresh_token', refreshToken);
  }

  Future<void> saveUserId(String userId) async {
    await _box.put('user_id', userId);
  }

  Future<void> clearTokens() async {
    await _box.delete('access_token');
    await _box.delete('refresh_token');
    await _box.delete('user_id');
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
