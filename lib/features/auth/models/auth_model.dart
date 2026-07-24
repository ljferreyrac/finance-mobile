/// Response returned by login, register, and token-refresh endpoints.
class AuthResponse {
  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  final String accessToken;
  final String refreshToken;

  /// Always "Bearer" per the backend contract.
  final String tokenType;

  /// Lifetime of [accessToken] in seconds.
  final int expiresIn;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      tokenType: (json['tokenType'] as String?) ?? 'Bearer',
      expiresIn: (json['expiresIn'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'tokenType': tokenType,
        'expiresIn': expiresIn,
      };
}
