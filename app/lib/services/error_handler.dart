import '../services/api_exception.dart';

/// Classification of errors for UI display.
enum ErrorType { network, auth, server, unknown }

/// Centralized error handler.
/// No silent API failures — every error produces a visible result.
class ErrorHandler {
  /// Classify an error into a category.
  static ErrorType classify(Object error) {
    if (error is ApiException) {
      if (error.statusCode == 401) return ErrorType.auth;
      if (error.statusCode >= 500) return ErrorType.server;
      return ErrorType.server;
    }
    // SocketException, ClientException, TimeoutException, etc.
    final msg = error.toString().toLowerCase();
    if (msg.contains('socketexception') ||
        msg.contains('clientexception') ||
        msg.contains('timeout') ||
        msg.contains('handshake') ||
        msg.contains('connection refused') ||
        msg.contains('network is unreachable') ||
        msg.contains('no internet') ||
        msg.contains('failed host lookup')) {
      return ErrorType.network;
    }
    return ErrorType.unknown;
  }

  /// Produce a user-friendly message.
  static String userMessage(Object error) {
    if (error is ApiException) {
      if (error.statusCode == 401) {
        return 'Session expired. Please log in again.';
      }
      if (error.statusCode == 409) {
        return 'Action blocked: ${error.message}';
      }
      if (error.message.isNotEmpty) {
        return error.message;
      }
      return 'Something went wrong on the server (${error.statusCode}).';
    }

    final type = classify(error);
    switch (type) {
      case ErrorType.network:
        return 'No internet connection. Please check your network and try again.';
      case ErrorType.auth:
        return 'Session expired. Please log in again.';
      case ErrorType.server:
        return 'Server error. Please try again later.';
      case ErrorType.unknown:
        return 'Something went wrong. Please try again.';
    }
  }
}
