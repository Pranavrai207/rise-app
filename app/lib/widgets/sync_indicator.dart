import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Compact pill indicator for offline / syncing state.
/// Shows "Offline — cached data" when offline with a pulse,
/// transitions to "Syncing…" with spinner briefly on reconnect,
/// then fades out when fully online.
class SyncIndicator extends StatefulWidget {
  const SyncIndicator({
    super.key,
    required this.isOffline,
    required this.isSyncing,
  });

  final bool isOffline;
  final bool isSyncing;

  @override
  State<SyncIndicator> createState() => _SyncIndicatorState();
}

class _SyncIndicatorState extends State<SyncIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  bool get _visible => widget.isOffline || widget.isSyncing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: _visible
          ? _buildPill(isDark)
          : const SizedBox.shrink(key: ValueKey('hidden')),
    );
  }

  Widget _buildPill(bool isDark) {
    final isSyncing = widget.isSyncing && !widget.isOffline;

    final Color bgColor = isSyncing
        ? AppColors.info.withValues(alpha: 0.18)
        : AppColors.warning.withValues(alpha: 0.18);

    final Color textColor = isSyncing ? AppColors.info : AppColors.warning;

    return FadeTransition(
      key: ValueKey(isSyncing ? 'syncing' : 'offline'),
      opacity: isSyncing
          ? const AlwaysStoppedAnimation(1.0)
          : _pulse.drive(Tween(begin: 0.6, end: 1.0)),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: textColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSyncing)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: textColor,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: Icon(Icons.cloud_off_rounded, color: textColor, size: 16),
              ),
            Text(
              isSyncing ? 'Syncing…' : 'Offline — cached data',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
