import '../models/auth_models.dart';
import '../services/api_exception.dart';
import '../services/auth_api_service.dart';
import '../services/auth_secure_store.dart';

class AuthRepository {
  AuthRepository({
    AuthApiService? api,
    AuthSecureStore? secureStore,
  })  : _api = api ?? AuthApiService(),
        _secureStore = secureStore ?? AuthSecureStore();

  final AuthApiService _api;
  final AuthSecureStore _secureStore;

  TokenPair? _tokens;

  bool get isAuthenticated => _tokens != null;

  String? get accessToken => _tokens?.accessToken;

  Future<bool> restoreSession() async {
    _tokens = await _secureStore.readTokens();
    return isAuthenticated;
  }

  Future<void> login({required String email, required String password}) async {
    _tokens = await _api.login(email: email, password: password);
    await _secureStore.writeTokens(_tokens!);
  }

  Future<void> registerAndLogin({required String email, required String password}) async {
    await _api.register(email: email, password: password);
    await login(email: email, password: password);
  }

  Future<void> refreshAccessToken() async {
    final current = _tokens;
    if (current == null) return;

    final freshAccessToken = await _api.refreshAccessToken(refreshToken: current.refreshToken);
    _tokens = TokenPair(accessToken: freshAccessToken, refreshToken: current.refreshToken);
    await _secureStore.writeTokens(_tokens!);
  }

  Future<T> withAuthRetry<T>(Future<T> Function(String accessToken) run) async {
    final current = _tokens;
    if (current == null) {
      throw const ApiException(statusCode: 401, message: 'No active session');
    }

    try {
      return await run(current.accessToken);
    } on ApiException catch (e) {
      if (e.statusCode != 401) {
        rethrow;
      }

      try {
        await refreshAccessToken();
      } catch (_) {
        await logout();
        throw const ApiException(statusCode: 401, message: 'Session expired. Please login again.');
      }

      final refreshed = _tokens;
      if (refreshed == null) {
        await logout();
        throw const ApiException(statusCode: 401, message: 'Session expired. Please login again.');
      }

      try {
        return await run(refreshed.accessToken);
      } on ApiException catch (retryError) {
        if (retryError.statusCode == 401) {
          await logout();
          throw const ApiException(statusCode: 401, message: 'Session expired. Please login again.');
        }
        rethrow;
      }
    }
  }

  Future<void> logout() async {
    _tokens = null;
    await _secureStore.clear();
  }
}
