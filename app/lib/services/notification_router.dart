/// Maps notification route strings to tab indices or navigation actions.
/// Used by the notification center to deep-link into the correct screen.
class NotificationRouter {
  /// Resolve a route string to a tab index.
  /// Returns null if the route doesn't map to a known tab.
  static int? resolveTabIndex(String? route) {
    if (route == null) return null;
    switch (route) {
      case '/home':
      case '/streak':
        return 0; // Home / Dashboard
      case '/quests':
        return 1; // Tasks tab
      case '/library':
        return 2; // Library tab
      case '/profile':
        return 3; // Profile tab
      default:
        return null;
    }
  }

  /// Human-readable label for the route (used in notification preview).
  static String? routeLabel(String? route) {
    if (route == null) return null;
    switch (route) {
      case '/home':
        return 'Go to Home';
      case '/streak':
        return 'View Streak';
      case '/quests':
        return 'View Quests';
      case '/library':
        return 'Open Library';
      case '/profile':
        return 'View Profile';
      default:
        return null;
    }
  }
}
