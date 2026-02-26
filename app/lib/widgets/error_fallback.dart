import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'retry_button.dart';

/// Graceful fallback widget shown when a section fails to load.
/// Contains an error icon, friendly message, and a retry button.
class ErrorFallback extends StatelessWidget {
  const ErrorFallback({
    super.key,
    required this.message,
    required this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  final String message;
  final VoidCallback onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error.withValues(alpha: 0.12),
              ),
              child: Icon(icon, color: AppColors.error, size: 40),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'Something went wrong',
              style: AppTextStyles.h3(isDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTextStyles.caption(isDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            RetryButton(onRetry: onRetry),
          ],
        ),
      ),
    );
  }
}
