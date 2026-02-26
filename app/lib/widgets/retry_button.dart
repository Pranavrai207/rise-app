import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// A styled retry button using the design system.
class RetryButton extends StatelessWidget {
  const RetryButton({
    super.key,
    required this.onRetry,
    this.label = 'Retry',
  });

  final VoidCallback onRetry;
  final String label;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh_rounded, size: 20),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
        ),
      ),
    );
  }
}
