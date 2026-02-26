import 'package:flutter/foundation.dart';

import '../models/analytics_event.dart';

/// Abstract analytics interface.
/// Swap implementations to route events to Firebase, Mixpanel, etc.
abstract class AnalyticsService {
  /// Log a single event.
  void logEvent(AnalyticsEvent event);

  /// Convenience — log by type with optional properties.
  void log(AnalyticsEventType type, {Map<String, dynamic> properties = const {}}) {
    logEvent(AnalyticsEvent.now(type, properties: properties));
  }

  /// Called when app comes to foreground.
  void startSession();

  /// Called when app goes to background. Logs session duration automatically.
  void endSession();
}

/// Debug implementation — prints events to console.
/// Replace with a real backend adapter in production.
class DebugAnalyticsService extends AnalyticsService {
  final List<AnalyticsEvent> _eventLog = [];
  final Stopwatch _sessionTimer = Stopwatch();

  /// Read-only access to logged events (useful for testing).
  List<AnalyticsEvent> get eventLog => List.unmodifiable(_eventLog);

  @override
  void logEvent(AnalyticsEvent event) {
    _eventLog.add(event);
    debugPrint('[Analytics] ${event.type.name} | ${event.properties}');
  }

  @override
  void startSession() {
    _sessionTimer.reset();
    _sessionTimer.start();
    log(AnalyticsEventType.appOpened);
    debugPrint('[Analytics] Session started');
  }

  @override
  void endSession() {
    _sessionTimer.stop();
    final durationSeconds = _sessionTimer.elapsed.inSeconds;
    log(
      AnalyticsEventType.sessionDuration,
      properties: {'duration_seconds': durationSeconds},
    );
    debugPrint('[Analytics] Session ended — ${durationSeconds}s');
  }
}
