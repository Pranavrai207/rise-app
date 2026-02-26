import 'package:flutter/material.dart';

import '../models/app_notification.dart';
import '../services/notification_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/animations/tap_scale.dart';
import '../widgets/empty_state.dart';
import '../widgets/glass_card.dart';

/// In-app notification center screen.
/// Displays a list of notifications with icons, timestamps, and deep-link routing.
class NotificationCenter extends StatefulWidget {
  const NotificationCenter({
    super.key,
    required this.notifications,
    required this.onNotificationTap,
    required this.onMarkAllRead,
  });

  final List<AppNotification> notifications;
  final ValueChanged<AppNotification> onNotificationTap;
  final VoidCallback onMarkAllRead;

  @override
  State<NotificationCenter> createState() => _NotificationCenterState();
}

class _NotificationCenterState extends State<NotificationCenter> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (widget.notifications.isNotEmpty)
            TextButton(
              onPressed: widget.onMarkAllRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.bgGradient(isDark),
          ),
        ),
        child: widget.notifications.isEmpty
            ? const EmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'All caught up!',
                description: 'No notifications right now. Keep building your streak!',
                iconColor: AppColors.primary,
              )
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
                itemCount: widget.notifications.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.itemGap),
                itemBuilder: (context, index) {
                  final notif = widget.notifications[index];
                  return _NotificationCard(
                    notification: notif,
                    isDark: isDark,
                    onTap: () => widget.onNotificationTap(notif),
                  );
                },
              ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.isDark,
    required this.onTap,
  });

  final AppNotification notification;
  final bool isDark;
  final VoidCallback onTap;

  IconData get _icon {
    switch (notification.type) {
      case NotificationType.dailyReminder:
        return Icons.alarm_rounded;
      case NotificationType.streakWarning:
        return Icons.local_fire_department_rounded;
      case NotificationType.rewardUnlocked:
        return Icons.emoji_events_rounded;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case NotificationType.dailyReminder:
        return AppColors.info;
      case NotificationType.streakWarning:
        return AppColors.warning;
      case NotificationType.rewardUnlocked:
        return AppColors.success;
    }
  }

  String get _timeAgo {
    final diff = DateTime.now().difference(notification.timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  @override
  Widget build(BuildContext context) {
    final routeLabel = NotificationRouter.routeLabel(notification.route);

    return TapScale(
      onTap: onTap,
      child: GlassCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread dot
            if (!notification.read)
              Container(
                margin: const EdgeInsets.only(top: 6, right: AppSpacing.sm),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              )
            else
              const SizedBox(width: 16),

            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _iconColor.withValues(alpha: isDark ? 0.18 : 0.14),
                borderRadius: BorderRadius.circular(AppSpacing.iconBoxRadius),
              ),
              child: Icon(_icon, color: _iconColor, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTextStyles.cardTitle(isDark).copyWith(
                            fontWeight: notification.read
                                ? FontWeight.w500
                                : FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        _timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted(isDark),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: AppTextStyles.subtitle(isDark),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (routeLabel != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      routeLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
