import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Base shimmer effect widget. Provides a pulsing animation
/// that mimics content loading.
class SkeletonCard extends StatefulWidget {
  const SkeletonCard({
    super.key,
    this.width,
    this.height = 20,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final double? borderRadius;

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? AppColors.darkCard.withValues(alpha: 0.5)
        : AppColors.lightCard;
    final highlightColor = isDark
        ? AppColors.darkCardSecondary.withValues(alpha: 0.8)
        : const Color(0xFFD6E0F0);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? AppSpacing.sm,
            ),
            color: Color.lerp(baseColor, highlightColor, _animation.value),
          ),
        );
      },
    );
  }
}

/// A shimmer row with an icon box + two text lines.
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        color: isDark
            ? AppColors.darkCard.withValues(alpha: 0.2)
            : AppColors.lightCard.withValues(alpha: 0.3),
      ),
      child: const Row(
        children: [
          SkeletonCard(
            width: 86,
            height: 86,
            borderRadius: AppSpacing.iconBoxRadius,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonCard(height: 20, width: 160),
                SizedBox(height: 8),
                SkeletonCard(height: 14, width: 120),
              ],
            ),
          ),
          SizedBox(width: 10),
          SkeletonCard(width: 58, height: 58, borderRadius: 29),
        ],
      ),
    );
  }
}
