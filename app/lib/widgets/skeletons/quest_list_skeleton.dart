import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import 'skeleton_card.dart';

/// Shimmer skeleton matching the Quests tab layout:
/// Header + 4 quest card placeholders.
class QuestListSkeleton extends StatelessWidget {
  const QuestListSkeleton({super.key});

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
                SkeletonCard(width: 80, height: 22),
                SizedBox(height: 6),
                SkeletonCard(width: 100, height: 16),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sectionGap),

        // 4 quest card skeletons
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(4, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.itemGap),
                  child: _QuestCardSkeleton(),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuestCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonCard(width: 180, height: 20),
                SizedBox(height: 8),
                SkeletonCard(width: 140, height: 14),
              ],
            ),
          ),
          SizedBox(width: 10),
          SkeletonCard(width: 90, height: 36, borderRadius: AppSpacing.md),
        ],
      ),
    );
  }
}
