import 'package:shared_preferences/shared_preferences.dart';

import '../models/streak_data.dart';

/// Local-first streak tracking engine.
///
/// Persists streak data to SharedPreferences so streaks survive app restarts.
/// Designed to work offline — the backend streak is used as a hint but this
/// service is the source of truth for client-side display.
class StreakService {
  static const _currentKey = 'streak_current';
  static const _bestKey = 'streak_best';
  static const _lastDateKey = 'streak_last_date';

  StreakData _cached = const StreakData();

  StreakData get current => _cached;

  /// Load persisted streak data.
  Future<StreakData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_currentKey) ?? 0;
    final best = prefs.getInt(_bestKey) ?? 0;
    final lastDateStr = prefs.getString(_lastDateKey);
    final lastDate = lastDateStr != null ? DateTime.tryParse(lastDateStr) : null;

    _cached = StreakData(
      currentStreak: current,
      bestStreak: best,
      lastCompletionDate: lastDate,
    );
    return _cached;
  }

  /// Record that the user completed all daily habits on [date].
  ///
  /// - Same day → no-op (already recorded)
  /// - Next consecutive day → increment streak
  /// - Gap > 1 day → reset streak to 1
  Future<StreakData> recordDayComplete(DateTime date) async {
    final today = DateTime(date.year, date.month, date.day);
    final last = _cached.lastCompletionDate;

    if (last != null) {
      final lastDay = DateTime(last.year, last.month, last.day);
      final diff = today.difference(lastDay).inDays;

      if (diff == 0) {
        // Same day — already recorded
        return _cached;
      } else if (diff == 1) {
        // Consecutive day — increment
        final newStreak = _cached.currentStreak + 1;
        final newBest =
            newStreak > _cached.bestStreak ? newStreak : _cached.bestStreak;
        _cached = StreakData(
          currentStreak: newStreak,
          bestStreak: newBest,
          lastCompletionDate: today,
        );
      } else {
        // Gap — reset
        _cached = StreakData(
          currentStreak: 1,
          bestStreak: _cached.bestStreak,
          lastCompletionDate: today,
        );
      }
    } else {
      // First ever completion
      _cached = StreakData(
        currentStreak: 1,
        bestStreak: 1,
        lastCompletionDate: today,
      );
    }

    await _persist();
    return _cached;
  }

  /// Check if streak is still alive given the current time.
  bool isStreakAlive([DateTime? now]) {
    return _cached.isAlive(now ?? DateTime.now());
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentKey, _cached.currentStreak);
    await prefs.setInt(_bestKey, _cached.bestStreak);
    if (_cached.lastCompletionDate != null) {
      await prefs.setString(
          _lastDateKey, _cached.lastCompletionDate!.toIso8601String());
    }
  }
}
