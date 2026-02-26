import 'package:flutter/foundation.dart';

String resolveApiBaseUrl() {
  const configured = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  if (configured.isNotEmpty) {
    return configured;
  }

  if (kIsWeb) {
    return 'http://127.0.0.1:8000';
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      // Using Computer's Local IP for Physical Device Connection
      return 'http://192.168.1.7:8000';
    default:
      return 'http://127.0.0.1:8000';
  }
}
