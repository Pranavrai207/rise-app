import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/analytics_event.dart';
import '../models/app_notification.dart';
import '../models/habit.dart';
import '../models/profile.dart';
import '../models/progression.dart';
import '../models/quest.dart';
import '../models/streak_data.dart';
import '../repositories/auth_repository.dart';
import '../repositories/habit_repository.dart';
import '../screens/notification_center.dart' as notif_screen;
import '../services/achievement_service.dart';
import '../services/analytics_service.dart';
import '../services/api_exception.dart';
import '../services/connectivity_service.dart';
import '../services/error_handler.dart';
import '../services/notification_router.dart';
import '../services/streak_service.dart';
import '../services/weekly_log_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/achievement_sheet.dart';
import '../widgets/bottom_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_fallback.dart';
import '../widgets/glass_card.dart';
import '../widgets/sync_indicator.dart';
import '../widgets/animations/tap_scale.dart';
import '../widgets/dashboard_summary.dart';
import '../widgets/ritual_card.dart';
import '../widgets/skeletons/dashboard_skeleton.dart';
import '../widgets/skeletons/profile_skeleton.dart';
import '../widgets/skeletons/quest_list_skeleton.dart';
import '../widgets/skeletons/skeleton_card.dart';
import '../widgets/top_header.dart';
import '../widgets/weekly_summary_card.dart';

class SanctumScreen extends StatefulWidget {
  const SanctumScreen({
    super.key,
    required this.authRepository,
    required this.habitRepository,
    required this.onLogout,
    required this.onSessionExpired,
    required this.themeMode,
    required this.onToggleTheme,
    this.connectivityService,
    this.analyticsService,
    this.streakService,
    this.achievementService,
    this.weeklyLogService,
  });

  final AuthRepository authRepository;
  final HabitRepository habitRepository;
  final Future<void> Function() onLogout;
  final Future<void> Function(String message) onSessionExpired;
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;
  final ConnectivityService? connectivityService;
  final AnalyticsService? analyticsService;
  final StreakService? streakService;
  final AchievementService? achievementService;
  final WeeklyLogService? weeklyLogService;

  @override
  State<SanctumScreen> createState() => _SanctumScreenState();
}

class _SanctumScreenState extends State<SanctumScreen> {
  List<Habit> _habits = [];
  List<QuestItem> _quests = [];
  ProgressionSnapshot? _progression;
  ProfileSnapshot? _profile;

  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _isNetworkError = false;
  bool _isOffline = false;
  bool _isSyncing = false;
  bool _isQuestsLoading = false;
  bool _isProfileLoading = false;

  // Notifications
  List<AppNotification> _notifications = [];
  int get _unreadCount => _notifications.where((n) => !n.read).length;

  // Analytics — track previous streak to detect breaks
  int _previousStreak = -1;

  // Phase 5 — Streak, Achievements, Weekly
  StreakData _streakData = const StreakData();
  List<DayLog> _weekLogs = [];
  bool _showWeeklySummary = true;

  int _selectedTab = 0;

  /// Safety flag — set during deactivate() BEFORE inherited widgets clean up.
  bool _isDeactivated = false;

  int get _completedCount => _habits.where((habit) => habit.completed).length;

  double get _completionRate => _habits.isEmpty ? 0 : _completedCount / _habits.length;

  int _localXpForType(HabitType type) {
    final completedForType = _habits.where((habit) => habit.type == type && habit.completed).length;
    return completedForType * 120;
  }

  String get _rank {
    final remoteLabel = _progression?.auraLabel;
    if (remoteLabel != null && remoteLabel.isNotEmpty) {
      return remoteLabel;
    }

    final percent = (_completionRate * 100).round();
    if (percent >= 90) return 'Ascendant';
    if (percent >= 70) return 'Adept';
    if (percent >= 40) return 'Novice Seeker';
    return 'Initiate';
  }

  int get _chakraXp => _progression?.chakraXp ?? _localXpForType(HabitType.chakra);

  int get _vitalityXp => _progression?.vitalityXp ?? _localXpForType(HabitType.vitality);

  int get _focusXp => _progression?.focusXp ?? _localXpForType(HabitType.focus);

  @override
  void initState() {
    super.initState();
    widget.connectivityService?.isOnline.addListener(_onConnectivityChanged);
    _isOffline = !(widget.connectivityService?.isOnline.value ?? true);
    _loadDashboard();
    _loadPhase5Data();
    // Analytics: app opened
    widget.analyticsService?.log(AnalyticsEventType.appOpened);
  }

  /// Load streak, achievements, and weekly log data.
  Future<void> _loadPhase5Data() async {
    final streakData = await widget.streakService?.load();
    await widget.achievementService?.load();
    await widget.weeklyLogService?.load();
    if (!mounted) return;
    setState(() {
      if (streakData != null) _streakData = streakData;
      _weekLogs = widget.weeklyLogService?.getWeekLogs() ?? [];
    });
  }

  @override
  void deactivate() {
    // Remove listener BEFORE inherited widgets check their dependents.
    _isDeactivated = true;
    widget.connectivityService?.isOnline.removeListener(_onConnectivityChanged);
    super.deactivate();
  }

  @override
  void dispose() {
    // Listener already removed in deactivate.
    super.dispose();
  }

  void _onConnectivityChanged() {
    if (_isDeactivated || !mounted) return;
    final online = widget.connectivityService?.isOnline.value ?? true;

    if (online && _isOffline) {
      // Came back online — auto-resync
      setState(() {
        _isOffline = false;
        _isSyncing = true;
        _isNetworkError = false;
      });
      _loadDashboard().then((_) {
        if (mounted) setState(() => _isSyncing = false);
      });
    } else if (!online) {
      setState(() => _isOffline = true);
    }
  }


  void _openNotificationCenter() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => notif_screen.NotificationCenter(
          notifications: _notifications,
          onNotificationTap: (notif) {
            // Mark as read
            setState(() {
              _notifications = _notifications.map((n) {
                return n.id == notif.id ? n.copyWith(read: true) : n;
              }).toList();
            });
            // Navigate to route
            final tabIndex = NotificationRouter.resolveTabIndex(notif.route);
            Navigator.of(context).pop();
            if (tabIndex != null) {
              setState(() => _selectedTab = tabIndex);
            }
          },
          onMarkAllRead: () {
            setState(() {
              _notifications = _notifications.map((n) => n.copyWith(read: true)).toList();
            });
          },
        ),
      ),
    );
  }

  Future<void> _updateAvatar(String type) async {
    if (widget.authRepository.accessToken == null) return;
    setState(() => _isProfileLoading = true);
    try {
      final updated = await widget.habitRepository.updateAvatar(
        avatarType: type,
      );
      if (mounted) {
        setState(() {
          _profile = updated;
          _isProfileLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProfileLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update avatar: $e')),
        );
      }
    }
  }

  void _showAvatarSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBg : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select Your Avatar', style: AppTextStyles.h2(isDark)),
            const SizedBox(height: AppSpacing.xl),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              children: [
                _buildAvatarOption('neutral', 'Balanced', Icons.person_rounded, isDark),
                _buildAvatarOption('chakra', 'Spiritual', Icons.auto_awesome, isDark),
                _buildAvatarOption('vitality', 'Energetic', Icons.bolt, isDark),
                _buildAvatarOption('focus', 'Analytical', Icons.psychology, isDark),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarOption(String type, String label, IconData icon, bool isDark) {
    final isSelected = _profile?.avatarType == type;
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _updateAvatar(type);
      },
      child: GlassCard(
        borderColor: isSelected ? AppColors.primary : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 60,
              width: 60,
              child: ClipOval(
                child: Image.asset(
                  _getAvatarAsset(type),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    icon,
                    size: 40,
                    color: isSelected ? AppColors.primary : (isDark ? Colors.white70 : Colors.black54),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(label, style: AppTextStyles.cardSubtitle(isDark)),
          ],
        ),
      ),
    );
  }

  String _getAvatarAsset(String type) {
    switch (type) {
      case 'chakra':
        return 'assets/avatars/avatar_chakra.png';
      case 'vitality':
        return 'assets/avatars/avatar_vitality.png';
      case 'focus':
        return 'assets/avatars/avatar_focus.png';
      default:
        return 'assets/avatars/avatar_neutral.png';
    }
  }

  Future<void> _handleApiFailure(Object error) async {
    if (_isDeactivated) return;
    if (error is ApiException && error.statusCode == 401) {
      await widget.onSessionExpired(ErrorHandler.userMessage(error));
      return;
    }

    if (!mounted) return;

    final errorType = ErrorHandler.classify(error);
    final message = ErrorHandler.userMessage(error);

    setState(() {
      _isNetworkError = errorType == ErrorType.network;
    });

    if (!mounted) return;
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _loadDashboard,
          ),
        ),
      );
    } catch (_) {
      // Widget tree may have been disposed — safe to ignore.
    }
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
      _isNetworkError = false;
    });

    try {
      final habits = await widget.habitRepository.loadHabits();
      final progression = await widget.habitRepository.loadProgression();
      final quests = await widget.habitRepository.loadQuests();
      final profile = await widget.habitRepository.loadProfile();

      if (!mounted) return;

      setState(() {
        _habits = habits;
        _progression = progression;
        _quests = quests;
        _profile = profile;
        _isLoading = false;
      });

      // Analytics: detect streak broken
      final currentStreak = progression?.streak ?? 0;
      if (_previousStreak > 0 && currentStreak == 0) {
        widget.analyticsService?.log(
          AnalyticsEventType.streakBroken,
          properties: {'previous_streak': _previousStreak},
        );
      }
      _previousStreak = currentStreak;
    } catch (error) {
      if (!mounted) return;

      final errorType = ErrorHandler.classify(error);
      final message = ErrorHandler.userMessage(error);

      if (error is ApiException && error.statusCode == 401) {
        await widget.onSessionExpired(message);
        return;
      }

      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = message;
        _isNetworkError = errorType == ErrorType.network;
      });
    }
  }

  Future<void> _syncProgression() async {
    try {
      final progression = await widget.habitRepository.loadProgression();
      final profile = await widget.habitRepository.loadProfile();
      if (!mounted) return;

      setState(() {
        _progression = progression;
        _profile = profile;
      });
    } catch (error) {
      await _handleApiFailure(error);
    }
  }

  Future<void> _syncQuests() async {
    setState(() => _isQuestsLoading = true);
    try {
      final quests = await widget.habitRepository.loadQuests();
      if (!mounted) return;
      setState(() {
        _quests = quests;
        _isQuestsLoading = false;
      });
    } catch (error) {
      if (mounted) setState(() => _isQuestsLoading = false);
      await _handleApiFailure(error);
    }
  }

  Future<void> _persistHabits() async {
    await widget.habitRepository.saveHabits(_habits);
  }

  Future<void> _toggleHabit(int index) async {
    setState(() {
      _habits[index].completed = !_habits[index].completed;
    });

    // Haptic feedback on completion
    if (_habits[index].completed) {
      HapticFeedback.mediumImpact();
    }

    await _persistHabits();
    if (!mounted) return;
    try {
      await widget.habitRepository.syncCompletion(_habits[index]);
      if (!mounted) return;
      await _syncProgression();
    } catch (error) {
      if (!mounted) return;
      await _handleApiFailure(error);
    }

    if (!mounted) return;
    // Check if all habits completed → update streak
    if (_habits.every((h) => h.completed)) {
      final updated = await widget.streakService?.recordDayComplete(DateTime.now());
      if (updated != null && mounted) {
        setState(() => _streakData = updated);
        // Haptic on streak milestone
        if (updated.currentStreak == 3 ||
            updated.currentStreak == 7 ||
            updated.currentStreak == 30) {
          HapticFeedback.heavyImpact();
        }
      }
    }

    if (!mounted) return;
    // Log weekly stats
    await widget.weeklyLogService?.logDay(
      date: DateTime.now(),
      completedCount: _completedCount,
      totalCount: _habits.length,
    );
    if (mounted) {
      setState(() {
        _weekLogs = widget.weeklyLogService?.getWeekLogs() ?? [];
      });
    }

    if (!mounted) return;
    // Check achievements
    await _checkAchievements();
  }

  Future<void> _addHabit() async {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    HabitType selectedType = HabitType.focus;

    final createdHabit = await showModalBottomSheet<Habit>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.lg, AppSpacing.lg,
            MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
          ),
          child: GlassCard(
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add task', style: AppTextStyles.h2(isDark)),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Task name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: subtitleController,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<HabitType>(
                      initialValue: selectedType,
                      items: HabitType.values
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.label),
                            ),
                          )
                          .toList(),
                      onChanged: (type) {
                        if (type == null) return;
                        setModalState(() => selectedType = type);
                      },
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: AppSpacing.cardPaddingH),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          final title = titleController.text.trim();
                          final subtitle = subtitleController.text.trim();
                          if (title.isEmpty || subtitle.isEmpty) return;

                          Navigator.of(context).pop(
                            Habit(
                              id: DateTime.now().microsecondsSinceEpoch.toString(),
                              title: title,
                              subtitle: subtitle,
                              type: selectedType,
                            ),
                          );
                        },
                        child: const Text('Add task'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );

    titleController.dispose();
    subtitleController.dispose();

    if (createdHabit != null) {
      try {
        final persistedHabit = await widget.habitRepository.addHabit(createdHabit);
        if (!mounted || _isDeactivated) return;
        setState(() {
          _habits.insert(0, persistedHabit);
        });
        await _persistHabits();
        if (!mounted || _isDeactivated) return;
        await _syncProgression();
      } catch (error) {
        if (!mounted || _isDeactivated) return;
        await _handleApiFailure(error);
      }
    }
  }

  Future<void> _addQuest() async {
    final titleController = TextEditingController();
    final notesController = TextEditingController();

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.lg, AppSpacing.lg,
            MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
          ),
          child: GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add task', style: AppTextStyles.h2(isDark)),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Task title'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
                const SizedBox(height: AppSpacing.cardPaddingH),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (titleController.text.trim().isEmpty) return;
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Add task'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (created == true) {
      try {
        final quest = await widget.habitRepository.addQuest(
          title: titleController.text.trim(),
          notes: notesController.text.trim(),
        );
        if (!mounted || _isDeactivated) return;
        setState(() {
          _quests.insert(0, quest);
        });
        // Analytics: quest created
        widget.analyticsService?.log(
          AnalyticsEventType.questCreated,
          properties: {'quest_title': quest.title},
        );
      } catch (error) {
        if (!mounted || _isDeactivated) return;
        await _handleApiFailure(error);
      }
    }

    titleController.dispose();
    notesController.dispose();
  }

  Future<void> _markQuestDone(QuestItem quest) async {
    try {
      final updated = await widget.habitRepository.setQuestDone(quest.id);
      if (!mounted) return;
      setState(() {
        _quests = _quests.map((q) => q.id == updated.id ? updated : q).toList();
      });
      // Haptic feedback
      HapticFeedback.heavyImpact();
      // Analytics: quest completed
      widget.analyticsService?.log(
        AnalyticsEventType.questCompleted,
        properties: {'quest_title': quest.title},
      );
      // Check achievements
      if (!mounted) return;
      await _checkAchievements();
    } catch (error) {
      if (!mounted) return;
      await _handleApiFailure(error);
    }
  }

  /// Evaluate achievement unlock conditions after key actions.
  Future<void> _checkAchievements() async {
    if (widget.achievementService == null || !mounted) return;

    final totalXp = _progression?.totalXp ?? (_chakraXp + _vitalityXp + _focusXp);
    final completedQuests = _quests.where((q) => q.status.toLowerCase() == 'done').length;

    final newlyUnlocked = await widget.achievementService!.checkAndUnlock(
      streak: _streakData,
      totalXp: totalXp,
      completedHabitsToday: _completedCount,
      totalHabitsToday: _habits.length,
      completedQuestsAllTime: completedQuests,
    );

    if (newlyUnlocked.isNotEmpty && mounted) {
      HapticFeedback.heavyImpact();
      for (final achievement in newlyUnlocked) {
        if (!mounted) break;
        try {
          showAchievementToast(context, achievement);
        } catch (_) {
          // Context may be invalid if widget was disposed.
        }
      }
    }
  }

  void _openAchievements() {
    final all = widget.achievementService?.getAll() ?? [];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AchievementSheet(achievements: all),
    );
  }

  // ── Tab builders ─────────────────────────────────────────────────────

  Widget _buildSanctumTab(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TopHeader(isDark: isDark, rank: _rank, level: _progression?.auraLevel ?? 1),
          const SizedBox(height: AppSpacing.sectionGap),
          DashboardSummary(
            isDark: isDark,
            streak: _streakData.currentStreak > 0
                ? _streakData.currentStreak
                : (_progression?.streak ?? 0),
            totalXp: _progression?.totalXp ?? (_chakraXp + _vitalityXp + _focusXp),
            nextLevelXp: _progression?.nextLevelXp ?? 1000,
            auraLevel: _progression?.auraLevel ?? 1,
            weeklyCompletionRate: _progression?.weeklyCompletionRate ?? _completionRate,
            completionRate: _completionRate,
            chakraXp: _chakraXp,
            vitalityXp: _vitalityXp,
            focusXp: _focusXp,
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          // Weekly Summary Card
          if (_showWeeklySummary && _weekLogs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sectionGap),
              child: WeeklySummaryCard(
                isDark: isDark,
                weekLogs: _weekLogs,
                currentStreak: _streakData.currentStreak,
                totalXpThisWeek: _progression?.totalXp ?? 0,
                onDismiss: () => setState(() => _showWeeklySummary = false),
              ),
            ),
          Text('TODAY TASKS', style: AppTextStyles.sectionLabel(isDark)),
          const SizedBox(height: AppSpacing.itemGap),
          if (_habits.isEmpty)
            EmptyState(
              icon: Icons.auto_stories_rounded,
              title: 'No habits yet',
              description: 'Start your journey by adding your first habit.',
              ctaLabel: 'Add Habit',
              onCta: _addHabit,
              iconColor: AppColors.primary,
            )
          else
            Column(
              children: _habits.asMap().entries.map((entry) {
                final index = entry.key;
                final habit = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: index == _habits.length - 1 ? 0 : AppSpacing.itemGap),
                  child: RitualCard(
                    habit: habit,
                    onToggle: () => _toggleHabit(index),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: AppSpacing.xxl * 2),
        ],
      ),
    );
  }

  Widget _buildQuestsTab(bool isDark) {
    if (_isQuestsLoading && _quests.isEmpty) {
      return const QuestListSkeleton();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TopHeader(isDark: isDark, rank: 'Tasks', level: _progression?.auraLevel ?? 1),
          const SizedBox(height: AppSpacing.sectionGap),
          if (_quests.isEmpty)
            EmptyState(
              icon: Icons.emoji_events_rounded,
              title: 'No quests yet',
              description: 'Create a quest to track bigger goals and milestones.',
              ctaLabel: 'Add Quest',
              onCta: _addQuest,
              iconColor: AppColors.vitality,
            )
          else
            Column(
              children: _quests.asMap().entries.map((entry) {
                final index = entry.key;
                final quest = entry.value;
                final isDone = quest.status.toLowerCase() == 'done';
                return Padding(
                  padding: EdgeInsets.only(bottom: index == _quests.length - 1 ? 0 : AppSpacing.itemGap),
                  child: GlassCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                quest.title,
                                style: isDone
                                    ? AppTextStyles.cardTitleCompleted(isDark)
                                    : AppTextStyles.cardTitle(isDark),
                              ),
                              const SizedBox(height: 6),
                              Text(quest.notes, style: AppTextStyles.bodySmall(isDark)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        FilledButton(
                          onPressed: isDone ? null : () => _markQuestDone(quest),
                          child: Text(isDone ? 'Done' : 'Mark Done'),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: AppSpacing.xxl * 2),
        ],
      ),
    );
  }

  Widget _buildProfileTab(bool isDark) {
    if (_isProfileLoading && _profile == null) {
      return const ProfileSkeleton();
    }

    final profile = _profile;
    if (profile == null) {
      return EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Profile unavailable',
        description: 'We couldn\'t load your profile data right now.',
        ctaLabel: 'Retry',
        onCta: () {
          setState(() => _isProfileLoading = true);
          _syncProgression().then((_) {
            if (mounted) setState(() => _isProfileLoading = false);
          });
        },
        iconColor: AppColors.warning,
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TopHeader(isDark: isDark, rank: profile.auraLabel, level: profile.auraLevel),
          const SizedBox(height: AppSpacing.sectionGap),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Avatar', style: AppTextStyles.h2(isDark)),
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
                      onPressed: _showAvatarSelector,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.2),
                          AppColors.accent.withValues(alpha: 0.2),
                        ],
                      ),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 2),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage(_getAvatarAsset(profile.avatarType)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Profile', style: AppTextStyles.h2(isDark)),
                const SizedBox(height: AppSpacing.md),
                Text('Email: ${profile.email}'),
                const SizedBox(height: AppSpacing.xs),
                Text('Aura Level: ${profile.auraLevel}'),
                const SizedBox(height: AppSpacing.xs),
                Text('Habits: ${profile.completedHabits}/${profile.totalHabits} complete'),
                const SizedBox(height: AppSpacing.sm),
                Text('Chakra XP: ${profile.chakraXp}'),
                Text('Vitality XP: ${profile.vitalityXp}'),
                Text('Focus XP: ${profile.focusXp}'),
                const SizedBox(height: AppSpacing.sm),
                // Streak stats
                Row(
                  children: [
                    Icon(Icons.local_fire_department_rounded,
                        color: _streakData.currentStreak > 0
                            ? AppColors.vitality
                            : AppColors.textMuted(isDark),
                        size: 20),
                    const SizedBox(width: 6),
                    Text('Streak: ${_streakData.currentStreak} days'),
                    const SizedBox(width: 16),
                    Text('Best: ${_streakData.bestStreak} days',
                        style: TextStyle(color: AppColors.textSecondary(isDark))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Achievements button
          GlassCard(
            child: InkWell(
              onTap: _openAchievements,
              borderRadius: BorderRadius.circular(26),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events_rounded,
                      color: AppColors.vitality, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Achievements', style: AppTextStyles.cardTitle(isDark)),
                        Text(
                          '${widget.achievementService?.unlockedCount ?? 0} / 9 unlocked',
                          style: AppTextStyles.bodySmall(isDark),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: AppColors.textMuted(isDark)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl * 2),
        ],
      ),
    );
  }

  Widget _buildAlmanacTab(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TopHeader(isDark: isDark, rank: 'Library', level: _progression?.auraLevel ?? 1),
          const SizedBox(height: AppSpacing.sectionGap),
          GlassCard(
            borderColor: AppColors.accent.withValues(alpha: 0.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.menu_book_rounded, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Text('Coming Soon', style: AppTextStyles.h3(isDark)),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'A curated collection of wisdom, meditation guides, and advanced focus techniques is being prepared for you.',
                  style: AppTextStyles.bodySmall(isDark),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          Text('SNEAK PEEK', style: AppTextStyles.sectionLabel(isDark)),
          const SizedBox(height: AppSpacing.md),
          const SkeletonCard(height: 100, borderRadius: AppSpacing.cardRadius),
          const SizedBox(height: AppSpacing.md),
          const SkeletonCard(height: 100, borderRadius: AppSpacing.cardRadius),
          const SizedBox(height: AppSpacing.md),
          const SkeletonCard(height: 100, borderRadius: AppSpacing.cardRadius),
        ],
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    // ── Global error state ──────────────────────────────────────────
    if (_hasError && !_isLoading) {
      // If offline but have cached habits, show them instead of blocking
      if (_isNetworkError && _habits.isNotEmpty) {
        // Fall through to content — SyncIndicator handles the offline message
      } else if (_isNetworkError) {
        return EmptyState(
          icon: Icons.cloud_off_rounded,
          title: 'You\'re offline',
          description: 'Connect to the internet to sync your data.',
          ctaLabel: 'Retry',
          onCta: _loadDashboard,
          iconColor: AppColors.warning,
        );
      } else {
        return ErrorFallback(
          message: _errorMessage ?? 'Something went wrong.',
          onRetry: _loadDashboard,
        );
      }
    }

    // ── Skeleton loading state ──────────────────────────────────────
    if (_isLoading) {
      switch (_selectedTab) {
        case 1:
          return const QuestListSkeleton();
        case 3:
          return const ProfileSkeleton();
        default:
          return const DashboardSkeleton();
      }
    }

    // ── Content ─────────────────────────────────────────────────────
    Widget content;
    switch (_selectedTab) {
      case 1:
        content = _buildQuestsTab(isDark);
        break;
      case 2:
        content = _buildAlmanacTab(isDark);
        break;
      case 3:
        content = _buildProfileTab(isDark);
        break;
      default:
        content = _buildSanctumTab(isDark);
    }

    return content;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              height: 32,
              width: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/brand/app_logo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text('Rise'),
          ],
        ),
        actions: [
          // Notification bell
          Stack(
            children: [
              IconButton(
                onPressed: _openNotificationCenter,
                icon: const Icon(Icons.notifications_none_rounded),
                tooltip: 'Notifications',
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.error,
                    ),
                    child: Text(
                      '$_unreadCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            onPressed: widget.onToggleTheme,
            icon: Icon(widget.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            tooltip: widget.themeMode == ThemeMode.dark ? 'Light mode' : 'Dark mode',
          ),
          IconButton(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
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
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -20,
              child: Container(
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.orbGlow(isDark),
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              left: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.orbGlowSecondary(isDark),
                ),
              ),
            ),
            Column(
              children: [
                // Sync indicator replaces network banner
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: SyncIndicator(
                    isOffline: _isOffline || (_isNetworkError && !_isLoading),
                    isSyncing: _isSyncing,
                  ),
                ),
                Expanded(
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPaddingH,
                        vertical: AppSpacing.screenPaddingV,
                      ),
                      child: _buildBody(isDark),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(
        isDark: isDark,
        selectedIndex: _selectedTab,
        onTap: (index) {
          setState(() {
            _selectedTab = index;
          });
          if (index == 1) {
            _syncQuests();
          }
          if (index == 3) {
            setState(() => _isProfileLoading = true);
            _syncProgression().then((_) {
              if (mounted) setState(() => _isProfileLoading = false);
            });
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: (_selectedTab == 0 || _selectedTab == 1)
          ? TapScale(
              onTap: _selectedTab == 0 ? _addHabit : _addQuest,
              child: Container(
                height: 76,
                width: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.darkBg : AppColors.lightBg,
                    width: 4,
                  ),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 38),
              ),
            )
          : null,
    );
  }

}
