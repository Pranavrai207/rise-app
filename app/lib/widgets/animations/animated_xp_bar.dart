import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Smooth XP progress bar that animates value changes with a spring curve.
/// Shows a gradient fill with a glow effect for premium feel.
class AnimatedXpBar extends StatelessWidget {
  const AnimatedXpBar({
    super.key,
    required this.value,
    this.height = 14.0,
    this.backgroundColor,
    this.gradientColors,
    this.label,
    this.duration = const Duration(milliseconds: 800),
  });

  /// Progress value between 0.0 and 1.0.
  final double value;
  final double height;
  final Color? backgroundColor;
  final List<Color>? gradientColors;
  final String? label;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ??
        (isDark ? AppColors.darkProgressBg : const Color(0xFFD6E0F0));
    final colors = gradientColors ?? [AppColors.primary, AppColors.primaryLight];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              label!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.progressBarRadius),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppSpacing.progressBarRadius),
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
              duration: duration,
              curve: Curves.easeOutCubic,
              builder: (context, animatedValue, _) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: animatedValue,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: colors),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.progressBarRadius),
                      boxShadow: [
                        BoxShadow(
                          color: colors.first.withValues(alpha: 0.45),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
