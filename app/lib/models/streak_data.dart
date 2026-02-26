/// Local-first streak snapshot persisted via SharedPreferences.
class StreakData {
  const StreakData({
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastCompletionDate,
  });

  final int currentStreak;
  final int bestStreak;
  final DateTime? lastCompletionDate;

  /// Whether the streak is still alive (completed today or yesterday).
  bool isAlive(DateTime now) {
    if (lastCompletionDate == null) return false;
    final diff = _daysBetween(lastCompletionDate!, now);
    return diff <= 1;
  }

  StreakData copyWith({
    int? currentStreak,
    int? bestStreak,
    DateTime? lastCompletionDate,
  }) {
    return StreakData(
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastCompletionDate: lastCompletionDate ?? this.lastCompletionDate,
    );
  }

  /// Number of calendar days between two dates (ignoring time).
  static int _daysBetween(DateTime a, DateTime b) {
    final aDate = DateTime(a.year, a.month, a.day);
    final bDate = DateTime(b.year, b.month, b.day);
    return bDate.difference(aDate).inDays.abs();
  }
}
