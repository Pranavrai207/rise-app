/// Types of analytics events tracked in the app.
enum AnalyticsEventType {
  questCreated,
  questCompleted,
  streakBroken,
  appOpened,
  sessionDuration,
}

/// Immutable analytics event with type, timestamp, and optional properties.
class AnalyticsEvent {
  const AnalyticsEvent({
    required this.type,
    required this.timestamp,
    this.properties = const {},
  });

  final AnalyticsEventType type;
  final DateTime timestamp;

  /// Arbitrary key-value pairs for event context.
  /// e.g. {'quest_title': 'Meditate', 'duration_seconds': 120}
  final Map<String, dynamic> properties;

  /// Convenience factory — auto-stamps current time.
  factory AnalyticsEvent.now(
    AnalyticsEventType type, {
    Map<String, dynamic> properties = const {},
  }) {
    return AnalyticsEvent(
      type: type,
      timestamp: DateTime.now(),
      properties: properties,
    );
  }

  @override
  String toString() =>
      'AnalyticsEvent(${type.name}, $timestamp, $properties)';
}
