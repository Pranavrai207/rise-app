import 'package:flutter/material.dart';

import '../models/achievement.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'glass_card.dart';

/// Bottom sheet displaying all achievements in a beautiful grid.
/// Unlocked achievements glow with their gradient; locked ones are muted.
class AchievementSheet extends StatelessWidget {
  const AchievementSheet({
    super.key,
    required this.achievements,
  });

  final List<Achievement> achievements;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBg : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.textMuted(isDark),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded,
                  color: AppColors.vitality, size: 28),
              const SizedBox(width: AppSpacing.sm),
              Text('Achievements', style: AppTextStyles.h2(isDark)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$unlockedCount / ${achievements.length}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Grid
          Flexible(
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: achievements.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) {
                return _AchievementTile(achievement: achievements[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unlocked = achievement.isUnlocked;

    return GlassCard(
      padding: const EdgeInsets.all(10),
      borderColor: unlocked ? achievement.gradientColors.first : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with gradient background
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: unlocked
                  ? LinearGradient(
                      colors: achievement.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: unlocked
                  ? null
                  : AppColors.textMuted(isDark).withValues(alpha: 0.15),
            ),
            child: Icon(
              achievement.icon,
              color: unlocked
                  ? Colors.white
                  : AppColors.textMuted(isDark).withValues(alpha: 0.5),
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          // Title
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: unlocked
                  ? AppColors.heading(isDark)
                  : AppColors.textMuted(isDark),
            ),
          ),
          const SizedBox(height: 2),
          // Description
          Text(
            achievement.description,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textMuted(isDark),
            ),
          ),
        ],
      ),
    );
  }
}

/// Celebratory snackbar shown when a new achievement is unlocked.
void showAchievementToast(BuildContext context, Achievement achievement) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(AppSpacing.lg),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: achievement.gradientColors.first,
      duration: const Duration(seconds: 3),
      content: Row(
        children: [
          Icon(achievement.icon, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🏆 Achievement Unlocked!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                Text(
                  achievement.title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
