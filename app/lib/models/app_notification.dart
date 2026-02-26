/// Types of in-app notifications.
enum NotificationType {
  dailyReminder,
  streakWarning,
  rewardUnlocked,
}

/// In-app notification model.
/// Supports push-to-UI rendering and deep-link routing.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    this.route,
    this.read = false,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime timestamp;

  /// Optional deep-link route, e.g. '/home', '/quests', '/profile', '/streak'.
  final String? route;
  final bool read;

  AppNotification copyWith({bool? read}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      timestamp: timestamp,
      route: route,
      read: read ?? this.read,
    );
  }
}
