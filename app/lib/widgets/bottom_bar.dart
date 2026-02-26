import 'dart:ui';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
    required this.isDark,
    required this.selectedIndex,
    required this.onTap,
  });

  final bool isDark;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final baseColor = AppColors.surface(isDark);
    final iconColor = AppColors.icon(isDark);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.navBarRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.lg),
          height: 90,
          decoration: BoxDecoration(
            color: baseColor.withValues(alpha: isDark ? 0.62 : 0.64),
            borderRadius: BorderRadius.circular(AppSpacing.navBarRadius),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.12) : AppColors.lightBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.45)
                    : const Color(0xFF9AAED0).withValues(alpha: 0.18),
                blurRadius: 26,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.grid_view_rounded,
                label: 'Home',
                active: selectedIndex == 0,
                color: iconColor,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.construction_rounded,
                label: 'Tasks',
                active: selectedIndex == 1,
                color: iconColor,
                onTap: () => onTap(1),
              ),
              const SizedBox(width: 58),
              _NavItem(
                icon: Icons.menu_book_rounded,
                label: 'Library',
                active: selectedIndex == 2,
                color: iconColor,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                active: selectedIndex == 3,
                color: iconColor,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool active;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    if (widget.active) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _controller.forward(from: 0.0);
    } else if (!widget.active && oldWidget.active) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xs),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Icon(widget.icon, color: widget.active ? AppColors.primary : widget.color, size: 30),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(widget.label, style: AppTextStyles.navLabel(active: widget.active, color: widget.color)),
          ],
        ),
      ),
    );
  }
}
