import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// A single day's log entry.
class DayLog {
  const DayLog({
    required this.date,
    required this.completedCount,
    required this.totalCount,
  });

  final DateTime date;
  final int completedCount;
  final int totalCount;

  double get rate => totalCount > 0 ? completedCount / totalCount : 0.0;

  Map<String, dynamic> toJson() => {
        'date': DateTime(date.year, date.month, date.day).toIso8601String(),
        'completed': completedCount,
        'total': totalCount,
      };

  factory DayLog.fromJson(Map<String, dynamic> json) => DayLog(
        date: DateTime.parse(json['date'] as String),
        completedCount: json['completed'] as int,
        totalCount: json['total'] as int,
      );
}

/// Persists daily completion stats for the past 7 days.
class WeeklyLogService {
  static const _key = 'weekly_log';

  List<DayLog> _logs = [];

  /// Load the weekly log from SharedPreferences.
  Future<List<DayLog>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      _logs = [];
      return _logs;
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    _logs = decoded
        .map((item) => DayLog.fromJson(item as Map<String, dynamic>))
        .toList();

    // Prune entries older than 7 days
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    _logs.removeWhere((log) => log.date.isBefore(cutoff));

    return List.unmodifiable(_logs);
  }

  /// Record today's completion stats.
  Future<void> logDay({
    required DateTime date,
    required int completedCount,
    required int totalCount,
  }) async {
    final today = DateTime(date.year, date.month, date.day);

    // Replace existing entry for today or add new
    _logs.removeWhere(
      (log) =>
          log.date.year == today.year &&
          log.date.month == today.month &&
          log.date.day == today.day,
    );
    _logs.add(DayLog(
      date: today,
      completedCount: completedCount,
      totalCount: totalCount,
    ));

    // Keep only last 7 days
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    _logs.removeWhere((log) => log.date.isBefore(cutoff));

    // Sort by date
    _logs.sort((a, b) => a.date.compareTo(b.date));

    await _persist();
  }

  /// Get logs for the past 7 days, filling gaps with zeroes.
  List<DayLog> getWeekLogs() {
    final now = DateTime.now();
    final result = <DayLog>[];

    for (int i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i));
      final existing = _logs.where(
        (log) =>
            log.date.year == day.year &&
            log.date.month == day.month &&
            log.date.day == day.day,
      );
      if (existing.isNotEmpty) {
        result.add(existing.first);
      } else {
        result.add(DayLog(date: day, completedCount: 0, totalCount: 0));
      }
    }

    return result;
  }

  /// Total completed habits this week.
  int get weeklyCompletedCount =>
      _logs.fold(0, (sum, log) => sum + log.completedCount);

  /// Best day this week by completion count.
  DayLog? get bestDay {
    if (_logs.isEmpty) return null;
    return _logs.reduce(
      (a, b) => a.completedCount >= b.completedCount ? a : b,
    );
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_logs.map((l) => l.toJson()).toList()),
    );
  }
}
