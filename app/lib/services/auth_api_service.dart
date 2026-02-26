import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/auth_models.dart';
import 'api_exception.dart';
import 'api_base_url.dart';

class AuthApiService {
  AuthApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? resolveApiBaseUrl();

  final http.Client _client;
  final String _baseUrl;

  Future<void> register({required String email, required String password}) async {
    final uri = Uri.parse('$_baseUrl/api/v1/auth/register');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    _throwOnFailure(response, fallback: 'Registration failed');
  }

  Future<TokenPair> login({required String email, required String password}) async {
    final uri = Uri.parse('$_baseUrl/api/v1/auth/login');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    _throwOnFailure(response, fallback: 'Login failed');

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return TokenPair(
      accessToken: (data['access_token'] ?? '').toString(),
      refreshToken: (data['refresh_token'] ?? '').toString(),
    );
  }

  Future<String> refreshAccessToken({required String refreshToken}) async {
    final uri = Uri.parse('$_baseUrl/api/v1/auth/refresh');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    _throwOnFailure(response, fallback: 'Token refresh failed');

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['access_token'] ?? '').toString();
  }

  void _throwOnFailure(http.Response response, {required String fallback}) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    String message = '$fallback (${response.statusCode})';
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        final backendMessage = body['message']?.toString();
        if (backendMessage != null && backendMessage.isNotEmpty) {
          message = backendMessage;
        }
      }
    } catch (_) {
      if (response.body.isNotEmpty) {
        message = response.body;
      }
    }

    throw ApiException(statusCode: response.statusCode, message: message);
  }
}
