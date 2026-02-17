import 'package:eventosapp/features/auth/domain/entities/user_entity.dart';

class AuthState {
  final bool isAuthenticated;
  final String? errorMessage;
  final UserEntity? user;
  final bool isLoading;

  const AuthState({
    this.isAuthenticated = false,
    this.errorMessage,
    this.user,
    this.isLoading = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? errorMessage,
    UserEntity? user,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  AuthState authenticated(UserEntity user) => copyWith(isAuthenticated: true, user: user);
  AuthState loading() => copyWith(isLoading: true, errorMessage: null);
  AuthState error(String message) => copyWith(errorMessage: message, isAuthenticated: false, isLoading: false);
  AuthState unauthenticated() => const AuthState();
}
