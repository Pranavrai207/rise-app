import 'package:flutter/material.dart';

import '../services/weekly_log_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'glass_card.dart';

/// Week recap card with a 7-day bar chart and summary stats.
class WeeklySummaryCard extends StatelessWidget {
  const WeeklySummaryCard({
    super.key,
    required this.isDark,
    required this.weekLogs,
    required this.currentStreak,
    required this.totalXpThisWeek,
    this.onDismiss,
  });

  final bool isDark;
  final List<DayLog> weekLogs;
  final int currentStreak;
  final int totalXpThisWeek;
  final VoidCallback? onDismiss;

  int get _weeklyCompleted =>
      weekLogs.fold(0, (sum, log) => sum + log.completedCount);

  String get _dateRange {
    if (weekLogs.isEmpty) return '';
    final start = weekLogs.first.date;
    final end = weekLogs.last.date;
    return '${_fmtDate(start)} – ${_fmtDate(end)}';
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String _fmtDate(DateTime d) => '${_months[d.month - 1]} ${d.day}';

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              const Icon(Icons.insights_rounded,
                  color: AppColors.accent, size: 22),
              const SizedBox(width: 8),
              Text('This Week', style: AppTextStyles.h2(isDark)),
              const Spacer(),
              if (onDismiss != null)
                GestureDetector(
                  onTap: onDismiss,
                  child: Icon(Icons.close_rounded,
                      size: 20, color: AppColors.textMuted(isDark)),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _dateRange,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted(isDark),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Stats row
          Row(
            children: [
              _StatPill(
                icon: Icons.check_circle_rounded,
                value: '$_weeklyCompleted',
                label: 'Done',
                color: AppColors.success,
                isDark: isDark,
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatPill(
                icon: Icons.local_fire_department_rounded,
                value: '$currentStreak',
                label: 'Streak',
                color: const Color(0xFFFF6B35),
                isDark: isDark,
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatPill(
                icon: Icons.bolt_rounded,
                value: '$totalXpThisWeek',
                label: 'XP',
                color: AppColors.vitality,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // 7-day bar chart
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weekLogs.map((log) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: _DayBar(log: log, isDark: isDark),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.14 : 0.10),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.heading(isDark),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({required this.log, required this.isDark});

  final DayLog log;
  final bool isDark;

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final rate = log.rate.clamp(0.0, 1.0);
    final dayLabel = _dayLabels[log.date.weekday - 1];
    final isToday = _isToday(log.date);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Bar
        Flexible(
          child: FractionallySizedBox(
            heightFactor: rate == 0 ? 0.05 : rate,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: rate > 0
                    ? const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [AppColors.primary, AppColors.accent],
                      )
                    : null,
                color: rate == 0
                    ? AppColors.textMuted(isDark).withValues(alpha: 0.15)
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Day label
        Text(
          dayLabel,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
            color: isToday
                ? AppColors.primary
                : AppColors.textMuted(isDark),
          ),
        ),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
