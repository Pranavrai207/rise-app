import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'animations/animated_xp_bar.dart';
import 'glass_card.dart';

/// Rich dashboard hero card with streak counter, XP bar,
/// weekly completion ring, and motivational micro-copy.
class DashboardSummary extends StatelessWidget {
  const DashboardSummary({
    super.key,
    required this.isDark,
    required this.streak,
    required this.totalXp,
    required this.nextLevelXp,
    required this.auraLevel,
    required this.weeklyCompletionRate,
    required this.completionRate,
    required this.chakraXp,
    required this.vitalityXp,
    required this.focusXp,
  });

  final bool isDark;
  final int streak;
  final int totalXp;
  final int nextLevelXp;
  final int auraLevel;
  final double weeklyCompletionRate;
  final double completionRate;
  final int chakraXp;
  final int vitalityXp;
  final int focusXp;

  String get _motivationalCopy {
    if (streak >= 30) return "🔥 Legendary streak! You're unstoppable.";
    if (streak >= 14) return "🌟 Two weeks strong — mastery in the making.";
    if (streak >= 7) return "⚡ One week down. Momentum is yours.";
    if (streak >= 3) return "✨ Three-day streak! Keep the rhythm alive.";
    if (streak >= 1) return "🌱 The journey begins with day one. Keep going!";
    if (completionRate >= 0.8) return "💪 Crushing it today — almost there!";
    if (completionRate >= 0.5) return "🎯 Half-way through. You've got this!";
    if (completionRate > 0) return "🚀 Great start! Finish the rest today.";
    return "☀️ A fresh day awaits. Start your first quest!";
  }

  @override
  Widget build(BuildContext context) {
    final xpFraction =
        nextLevelXp > 0 ? (totalXp / nextLevelXp).clamp(0.0, 1.0) : 0.0;
    final weeklyPercent = (weeklyCompletionRate * 100).round();
    final dailyPercent = (completionRate * 100).round();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row: Streak + Weekly Ring ──────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Streak counter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Daily Ascension',
                        style: AppTextStyles.ascensionTitle(isDark)),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: RichText(
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(children: [
                              TextSpan(
                                text: '$dailyPercent',
                                style: AppTextStyles.displayLarge(isDark),
                              ),
                              TextSpan(
                                text: '%',
                                style: AppTextStyles.displayUnit(isDark),
                              ),
                            ]),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        // Streak badge
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: streak > 0
                                  ? [
                                      const Color(0xFFFF6B35),
                                      const Color(0xFFFFAA33),
                                    ]
                                  : [
                                      AppColors.darkCard,
                                      AppColors.darkCardSecondary,
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_fire_department_rounded,
                                color: streak > 0
                                    ? Colors.white
                                    : AppColors.textMuted(isDark),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$streak',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: streak > 0
                                      ? Colors.white
                                      : AppColors.textMuted(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Weekly completion ring
              SizedBox(
                width: 80,
                height: 80,
                child: CustomPaint(
                  painter: _WeeklyRingPainter(
                    progress: weeklyCompletionRate.clamp(0.0, 1.0),
                    isDark: isDark,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$weeklyPercent%',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.heading(isDark),
                          ),
                        ),
                        Text(
                          'Week',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // ── XP Progress Bar ───────────────────────────────────
          AnimatedXpBar(
            value: xpFraction,
            label: 'Level $auraLevel — $totalXp / $nextLevelXp XP',
          ),
          const SizedBox(height: AppSpacing.md),

          // ── XP Category Row ───────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _XpChip(
                  label: 'Chakra',
                  xp: chakraXp,
                  color: AppColors.chakra,
                  isDark: isDark),
              _XpChip(
                  label: 'Vitality',
                  xp: vitalityXp,
                  color: AppColors.vitality,
                  isDark: isDark),
              _XpChip(
                  label: 'Focus',
                  xp: focusXp,
                  color: AppColors.focus,
                  isDark: isDark),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Motivational copy ─────────────────────────────────
          Text(
            _motivationalCopy,
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small XP chip ───────────────────────────────────────────────────
class _XpChip extends StatelessWidget {
  const _XpChip({
    required this.label,
    required this.xp,
    required this.color,
    required this.isDark,
  });

  final String label;
  final int xp;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.tagRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 6),
          Text(
            '$label $xp',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Weekly completion ring painter ──────────────────────────────────
class _WeeklyRingPainter extends CustomPainter {
  _WeeklyRingPainter({
    required this.progress,
    required this.isDark,
  });

  final double progress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const strokeWidth = 6.0;

    // Background track
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = isDark ? AppColors.darkProgressBg : const Color(0xFFD6E0F0);
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      // ignore: prefer_const_constructors
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: const [AppColors.primary, AppColors.accent],
      ).createShader(
          Rect.fromCircle(center: center, radius: radius));

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _WeeklyRingPainter old) =>
      old.progress != progress || old.isDark != isDark;
}
