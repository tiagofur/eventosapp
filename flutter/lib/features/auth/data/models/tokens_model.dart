class TokensModel {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  TokensModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory TokensModel.fromJson(Map<String, dynamic> json) {
    return TokensModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: json['expires_in'] as int,
    );
  }
}
