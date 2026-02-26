import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Reusable empty state widget.
/// Renders a centered column with a styled icon container, title,
/// description, and an optional call-to-action button.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.ctaLabel,
    this.onCta,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? ctaLabel;
  final VoidCallback? onCta;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = iconColor ?? AppColors.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration — large icon in a styled circle
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.18),
                    color.withValues(alpha: 0.08),
                  ],
                ),
                border: Border.all(
                  color: color.withValues(alpha: 0.25),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 48),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Title
            Text(
              title,
              style: AppTextStyles.h3(isDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),

            // Description
            Text(
              description,
              style: AppTextStyles.caption(isDark),
              textAlign: TextAlign.center,
            ),

            // CTA button
            if (ctaLabel != null && onCta != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              FilledButton.icon(
                onPressed: onCta,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(ctaLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
