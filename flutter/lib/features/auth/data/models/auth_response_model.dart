import 'package:eventosapp/features/auth/data/models/user_model.dart';
import 'package:eventosapp/features/auth/data/models/tokens_model.dart';

class AuthResponseModel {
  final UserModel user;
  final TokensModel tokens;

  AuthResponseModel({
    required this.user,
    required this.tokens,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      tokens: TokensModel.fromJson(json['tokens'] as Map<String, dynamic>),
    );
  }
}
