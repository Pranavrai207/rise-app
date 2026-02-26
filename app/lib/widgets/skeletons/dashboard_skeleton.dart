import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import 'skeleton_card.dart';

/// Shimmer skeleton matching the Sanctum (Home) tab layout:
/// Header + Progress panel + 3 habit card placeholders.
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

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
                SkeletonCard(width: 140, height: 22),
                SizedBox(height: 6),
                SkeletonCard(width: 100, height: 16),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sectionGap),

        // Progress panel skeleton
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
              SkeletonCard(width: 130, height: 18),
              SizedBox(height: 10),
              Row(
                children: [
                  SkeletonCard(width: 100, height: 56),
                  Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SkeletonCard(width: 110, height: 16),
                      SizedBox(height: 4),
                      SkeletonCard(width: 110, height: 16),
                      SizedBox(height: 4),
                      SkeletonCard(width: 110, height: 16),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12),
              SkeletonCard(height: 14, borderRadius: AppSpacing.progressBarRadius),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),

        // Section label skeleton
        const SkeletonCard(width: 140, height: 18),
        const SizedBox(height: AppSpacing.itemGap),

        // 3 habit card skeletons
        const Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SkeletonListTile(),
                SizedBox(height: AppSpacing.itemGap),
                SkeletonListTile(),
                SizedBox(height: AppSpacing.itemGap),
                SkeletonListTile(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
