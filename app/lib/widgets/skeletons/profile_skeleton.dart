import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import 'skeleton_card.dart';

/// Shimmer skeleton matching the Profile tab layout:
/// Header + profile card with field placeholders.
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header skeleton
        const Row(
          children: [
            SkeletonCard(width: 66, height: 66, borderRadius: 33),
            SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonCard(width: 120, height: 22),
                SizedBox(height: 6),
                SkeletonCard(width: 100, height: 16),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sectionGap),

        // Profile card skeleton
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.cardPaddingH,
            vertical: AppSpacing.cardPaddingV,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF202A44).withValues(alpha: 0.2)
                : const Color(0xFFEAF0FA).withValues(alpha: 0.3),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonCard(width: 80, height: 22),
              SizedBox(height: 16),
              SkeletonCard(width: 200, height: 16),
              SizedBox(height: 8),
              SkeletonCard(width: 160, height: 16),
              SizedBox(height: 8),
              SkeletonCard(width: 220, height: 16),
              SizedBox(height: 12),
              SkeletonCard(width: 140, height: 16),
              SizedBox(height: 8),
              SkeletonCard(width: 140, height: 16),
              SizedBox(height: 8),
              SkeletonCard(width: 140, height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
