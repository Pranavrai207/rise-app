class ProfileSnapshot {
  const ProfileSnapshot({
    required this.userId,
    required this.email,
    required this.totalHabits,
    required this.completedHabits,
    required this.chakraXp,
    required this.vitalityXp,
    required this.focusXp,
    required this.auraLevel,
    required this.auraLabel,
    required this.avatarType,
  });

  final String userId;
  final String email;
  final int totalHabits;
  final int completedHabits;
  final int chakraXp;
  final int vitalityXp;
  final int focusXp;
  final int auraLevel;
  final String auraLabel;
  final String avatarType;
}
