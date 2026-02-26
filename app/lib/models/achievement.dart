import 'package:flutter/material.dart';

/// Types of achievements that can be unlocked.
enum AchievementType {
  firstHabit,
  threeDayStreak,
  sevenDayStreak,
  thirtyDayStreak,
  hundredXp,
  fiveHundredXp,
  thousandXp,
  allDailyComplete,
  tenQuestsComplete,
}

/// An individual achievement badge.
class Achievement {
  const Achievement({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    this.unlockedAt,
  });

  final AchievementType type;
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final DateTime? unlockedAt;

  bool get isUnlocked => unlockedAt != null;

  Achievement unlock(DateTime at) => Achievement(
        type: type,
        title: title,
        description: description,
        icon: icon,
        gradientColors: gradientColors,
        unlockedAt: at,
      );

  /// All achievable badges with their metadata.
  static final List<Achievement> catalogue = [
    const Achievement(
      type: AchievementType.firstHabit,
      title: 'First Step',
      description: 'Complete your first habit',
      icon: Icons.emoji_events_rounded,
      gradientColors: [Color(0xFFFFD700), Color(0xFFFFA000)],
    ),
    const Achievement(
      type: AchievementType.threeDayStreak,
      title: 'Rising Flame',
      description: 'Maintain a 3-day streak',
      icon: Icons.local_fire_department_rounded,
      gradientColors: [Color(0xFFFF6B35), Color(0xFFFFAA33)],
    ),
    const Achievement(
      type: AchievementType.sevenDayStreak,
      title: 'Week Warrior',
      description: 'Maintain a 7-day streak',
      icon: Icons.shield_rounded,
      gradientColors: [Color(0xFF2E79FF), Color(0xFF4BC8FF)],
    ),
    const Achievement(
      type: AchievementType.thirtyDayStreak,
      title: 'Ascendant',
      description: 'Maintain a 30-day streak',
      icon: Icons.diamond_rounded,
      gradientColors: [Color(0xFF9C27B0), Color(0xFFE040FB)],
    ),
    const Achievement(
      type: AchievementType.hundredXp,
      title: 'Spark',
      description: 'Earn 100 XP',
      icon: Icons.bolt_rounded,
      gradientColors: [Color(0xFF22C55E), Color(0xFF86EFAC)],
    ),
    const Achievement(
      type: AchievementType.fiveHundredXp,
      title: 'Surge',
      description: 'Earn 500 XP',
      icon: Icons.flash_on_rounded,
      gradientColors: [Color(0xFFF4A11A), Color(0xFFFFD54F)],
    ),
    const Achievement(
      type: AchievementType.thousandXp,
      title: 'Tempest',
      description: 'Earn 1000 XP',
      icon: Icons.auto_awesome_rounded,
      gradientColors: [Color(0xFF5D63F3), Color(0xFF7C4DFF)],
    ),
    const Achievement(
      type: AchievementType.allDailyComplete,
      title: 'Perfect Day',
      description: 'Complete all habits in a single day',
      icon: Icons.stars_rounded,
      gradientColors: [Color(0xFFFF4081), Color(0xFFFF80AB)],
    ),
    const Achievement(
      type: AchievementType.tenQuestsComplete,
      title: 'Quest Master',
      description: 'Complete 10 quests',
      icon: Icons.military_tech_rounded,
      gradientColors: [Color(0xFF00BCD4), Color(0xFF26C6DA)],
    ),
  ];
}
