class ProgressionSnapshot {
  const ProgressionSnapshot({
    required this.chakraXp,
    required this.vitalityXp,
    required this.focusXp,
    required this.auraLevel,
    required this.auraLabel,
    this.avatarType = 'neutral',
    this.streak = 0,
    this.totalXp = 0,
    this.nextLevelXp = 1000,
    this.weeklyCompletionRate = 0.0,
  });

  final int chakraXp;
  final int vitalityXp;
  final int focusXp;
  final int auraLevel;
  final String auraLabel;
  final String avatarType;
  final int streak;
  final int totalXp;
  final int nextLevelXp;
  final double weeklyCompletionRate;
}
