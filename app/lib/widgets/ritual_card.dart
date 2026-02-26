import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'animations/animated_check.dart';
import 'animations/tap_scale.dart';
import 'glass_card.dart';

class RitualCard extends StatelessWidget {
  const RitualCard({
    super.key,
    required this.habit,
    required this.onToggle,
  });

  final Habit habit;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = habit.type.accent;

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: accent.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: isDark ? 0.08 : 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(26)),
                ),
              ),
              const SizedBox(width: 8),
            Container(
              height: 86,
              width: 86,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.iconBoxRadius),
                color: accent.withValues(alpha: isDark ? 0.17 : 0.20),
              ),
              child: Icon(habit.type.icon, color: accent, size: 38),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.title,
                    style: habit.completed
                        ? AppTextStyles.cardTitleCompleted(isDark)
                        : AppTextStyles.cardTitle(isDark),
                  ),
                  const SizedBox(height: 6),
                  Text(habit.subtitle, style: AppTextStyles.subtitle(isDark)),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: isDark ? 0.24 : 0.20),
                    borderRadius: BorderRadius.circular(AppSpacing.tagRadius),
                  ),
                  child: Text(habit.type.label, style: AppTextStyles.tag(accent)),
                ),
                const SizedBox(height: AppSpacing.md),
                TapScale(
                  onTap: onToggle,
                  child: Container(
                    height: 58,
                    width: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: habit.completed ? accent : AppColors.darkBorder,
                        width: 2,
                      ),
                      color: habit.completed ? accent.withValues(alpha: 0.18) : Colors.transparent,
                    ),
                    child: Center(
                      child: habit.completed
                          ? AnimatedCheck(
                              checked: true,
                              size: 30,
                              color: accent,
                            )
                          : Icon(
                              Icons.add,
                              color: isDark ? AppColors.darkIcon : AppColors.lightIcon,
                              size: 30,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }
}
