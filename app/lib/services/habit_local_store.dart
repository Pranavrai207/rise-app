import 'package:shared_preferences/shared_preferences.dart';

import '../models/habit.dart';

class HabitLocalStore {
  static const _habitsKey = 'secure_vibe_habits';
  static const _completionDateKey = 'secure_vibe_completion_date';

  Future<List<Habit>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_habitsKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    return Habit.decodeList(raw);
  }

  Future<void> saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_habitsKey, Habit.encodeList(habits));
  }

  /// Save the date when habits were last loaded / reset.
  Future<void> saveCompletionDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final dateOnly = DateTime(date.year, date.month, date.day);
    await prefs.setString(_completionDateKey, dateOnly.toIso8601String());
  }

  /// Load the last completion date for daily reset comparison.
  Future<DateTime?> loadCompletionDate() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_completionDateKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }
}
