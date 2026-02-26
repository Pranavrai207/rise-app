import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/achievement.dart';
import '../models/streak_data.dart';

/// Manages achievement unlock state via SharedPreferences.
///
/// Call [checkAndUnlock] after key user actions to evaluate whether
/// new achievements should be unlocked. Returns only *newly* unlocked
/// achievements so the caller can show celebration UI.
class AchievementService {
  static const _unlockedKey = 'achievements_unlocked';

  /// Map of type → unlock timestamp (ISO8601).
  Map<AchievementType, DateTime> _unlocked = {};

  /// Load previously unlocked achievements from disk.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_unlockedKey);
    if (raw == null || raw.isEmpty) {
      _unlocked = {};
      return;
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    _unlocked = decoded.map(
      (key, value) => MapEntry(
        AchievementType.values.firstWhere((t) => t.name == key),
        DateTime.parse(value as String),
      ),
    );
  }

  /// Get the full catalogue with unlock status applied.
  List<Achievement> getAll() {
    return Achievement.catalogue.map((a) {
      final unlockedAt = _unlocked[a.type];
      return unlockedAt != null ? a.unlock(unlockedAt) : a;
    }).toList();
  }

  /// Number of unlocked achievements.
  int get unlockedCount => _unlocked.length;

  /// Evaluate current stats and return any *newly* unlocked achievements.
  Future<List<Achievement>> checkAndUnlock({
    required StreakData streak,
    required int totalXp,
    required int completedHabitsToday,
    required int totalHabitsToday,
    required int completedQuestsAllTime,
  }) async {
    final now = DateTime.now();
    final newlyUnlocked = <Achievement>[];

    void tryUnlock(AchievementType type, bool condition) {
      if (!_unlocked.containsKey(type) && condition) {
        _unlocked[type] = now;
        final badge = Achievement.catalogue
            .firstWhere((a) => a.type == type)
            .unlock(now);
        newlyUnlocked.add(badge);
      }
    }

    // Habit milestones
    tryUnlock(AchievementType.firstHabit, completedHabitsToday >= 1);
    tryUnlock(
      AchievementType.allDailyComplete,
      totalHabitsToday > 0 && completedHabitsToday >= totalHabitsToday,
    );

    // Streak milestones
    tryUnlock(AchievementType.threeDayStreak, streak.currentStreak >= 3);
    tryUnlock(AchievementType.sevenDayStreak, streak.currentStreak >= 7);
    tryUnlock(AchievementType.thirtyDayStreak, streak.currentStreak >= 30);

    // XP milestones
    tryUnlock(AchievementType.hundredXp, totalXp >= 100);
    tryUnlock(AchievementType.fiveHundredXp, totalXp >= 500);
    tryUnlock(AchievementType.thousandXp, totalXp >= 1000);

    // Quest milestone
    tryUnlock(AchievementType.tenQuestsComplete, completedQuestsAllTime >= 10);

    if (newlyUnlocked.isNotEmpty) {
      await _persist();
    }

    return newlyUnlocked;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      _unlocked.map((key, value) => MapEntry(key.name, value.toIso8601String())),
    );
    await prefs.setString(_unlockedKey, encoded);
  }
}
