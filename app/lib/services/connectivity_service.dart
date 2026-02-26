import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_base_url.dart';

/// Lightweight connectivity checker.
/// Pings the API with a HEAD request and exposes a [ValueNotifier<bool>].
/// No native plugin required — works on all platforms.
class ConnectivityService {
  ConnectivityService({Duration? checkInterval, String? baseUrl})
      : _baseUrl = baseUrl ?? resolveApiBaseUrl(),
        _checkInterval = checkInterval ?? const Duration(seconds: 15);

  final String _baseUrl;
  final Duration _checkInterval;

  final ValueNotifier<bool> isOnline = ValueNotifier<bool>(true);
  Timer? _timer;
  bool _disposed = false;

  /// Start periodic connectivity checks.
  void start() {
    _check(); // immediate first check
    _timer = Timer.periodic(_checkInterval, (_) => _check());
  }

  /// Single connectivity check.
  Future<void> _check() async {
    if (_disposed) return;
    try {
      final uri = Uri.parse('$_baseUrl/api/v1/health');
      final response = await http.head(uri).timeout(const Duration(seconds: 5));
      _setOnline(response.statusCode < 500);
    } catch (_) {
      _setOnline(false);
    }
  }

  void _setOnline(bool value) {
    if (!_disposed && isOnline.value != value) {
      isOnline.value = value;
    }
  }

  /// Force-check connectivity now (e.g. on retry).
  Future<void> checkNow() => _check();

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    isOnline.dispose();
  }
}
