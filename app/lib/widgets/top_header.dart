import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class TopHeader extends StatelessWidget {
  const TopHeader({
    super.key,
    required this.isDark,
    required this.rank,
    required this.level,
  });

  final bool isDark;
  final String rank;
  final int level;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 66,
          width: 66,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.darkHeaderBgStart, AppColors.darkHeaderBgEnd],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 16,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/brand/app_logo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(rank, style: AppTextStyles.rank(isDark)),
            const SizedBox(height: 2),
            Text('Aura Level $level', style: AppTextStyles.headerSubtitle(isDark)),
          ],
        ),
        const Spacer(),
        const Icon(Icons.auto_awesome, color: AppColors.primary, size: 26),
      ],
    );
  }
}
