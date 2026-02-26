import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_models.dart';

class AuthSecureStore {
  static const _accessTokenKey = 'secure_vibe_access_token';
  static const _refreshTokenKey = 'secure_vibe_refresh_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<TokenPair?> readTokens() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    final refreshToken = await _storage.read(key: _refreshTokenKey);

    if (accessToken == null || refreshToken == null) {
      return null;
    }

    return TokenPair(accessToken: accessToken, refreshToken: refreshToken);
  }

  Future<void> writeTokens(TokenPair tokens) async {
    await _storage.write(key: _accessTokenKey, value: tokens.accessToken);
    await _storage.write(key: _refreshTokenKey, value: tokens.refreshToken);
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
