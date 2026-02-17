import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventosapp/core/api/api_client_provider.dart';
import 'package:eventosapp/core/storage/secure_storage.dart';
import 'package:eventosapp/features/auth/domain/repositories/auth_repository.dart';
import 'auth_state.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);

class AuthNotifier extends AsyncNotifier<AuthState> {
  late final AuthRepository _repository;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final response = await _repository.login(email: email, password: password);
      state = AsyncData(
        state.valueOrNull?.authenticated(response.user.toEntity()) ??
            AuthState(isAuthenticated: true, user: response.user.toEntity()),
      );
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncLoading();
    try {
      final response = await _repository.register(email: email, password: password, name: name);
      state = AsyncData(
        state.valueOrNull?.authenticated(response.user.toEntity()) ??
            AuthState(isAuthenticated: true, user: response.user.toEntity()),
      );
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> forgotPassword({
    required String email,
  }) async {
    state = const AsyncLoading();
    try {
      await _repository.forgotPassword(email: email);
      state = AsyncData(state.valueOrNull ?? const AuthState());
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      await _repository.logout();
      state = AsyncData(const AuthState());
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> checkAuthStatus() async {
    state = const AsyncLoading();
    try {
      final authResponse = await _repository.getCurrentUser();
      if (authResponse != null) {
        state = AsyncData(AuthState(isAuthenticated: true, user: authResponse.user.toEntity()));
      } else {
        state = AsyncData(const AuthState());
      }
    } catch (e) {
      state = AsyncData(const AuthState());
    }
  }

  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);
    return const AuthState();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthRepository(apiClient: apiClient, secureStorage: secureStorage);
});

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});
