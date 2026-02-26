import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'glass_card.dart';

class ProgressPanel extends StatelessWidget {
  const ProgressPanel({
    super.key,
    required this.isDark,
    required this.completionRate,
    required this.chakraXp,
    required this.vitalityXp,
    required this.focusXp,
  });

  final bool isDark;
  final double completionRate;
  final int chakraXp;
  final int vitalityXp;
  final int focusXp;

  @override
  Widget build(BuildContext context) {
    final completionPercent = (completionRate * 100).round();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Ascension', style: AppTextStyles.ascensionTitle(isDark)),
          const SizedBox(height: 6),
          Row(
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$completionPercent',
                      style: AppTextStyles.displayLarge(isDark),
                    ),
                    TextSpan(
                      text: '%',
                      style: AppTextStyles.displayUnit(isDark),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Chakra: $chakraXp XP', style: AppTextStyles.xpChakra),
                  const SizedBox(height: 2),
                  Text('Vitality: $vitalityXp XP', style: AppTextStyles.xpVitality),
                  const SizedBox(height: 2),
                  Text('Focus: $focusXp XP', style: AppTextStyles.xpFocus),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.progressBarRadius),
            child: LinearProgressIndicator(
              value: completionRate,
              minHeight: 14,
              backgroundColor: isDark ? AppColors.darkProgressBg : const Color(0xFFD6E0F0),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
