import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'repositories/auth_repository.dart';
import 'repositories/habit_repository.dart';
import 'screens/auth_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/sanctum_screen.dart';
import 'services/achievement_service.dart';
import 'services/analytics_service.dart';
import 'services/connectivity_service.dart';
import 'services/streak_service.dart';
import 'services/weekly_log_service.dart';
import 'theme/app_theme.dart';

class RiseApp extends StatefulWidget {
  const RiseApp({super.key});

  @override
  State<RiseApp> createState() => _RiseAppState();
}

class _RiseAppState extends State<RiseApp>
    with WidgetsBindingObserver {
  final AuthRepository _authRepository = AuthRepository();
  final ConnectivityService _connectivityService = ConnectivityService();
  final AnalyticsService _analyticsService = DebugAnalyticsService();
  final StreakService _streakService = StreakService();
  final AchievementService _achievementService = AchievementService();
  final WeeklyLogService _weeklyLogService = WeeklyLogService();
  late final HabitRepository _habitRepository = HabitRepository(
    authRepository: _authRepository,
    enableRemoteSync: const bool.fromEnvironment('ENABLE_REMOTE_SYNC', defaultValue: true),
    connectivityService: _connectivityService,
  );

  bool _ready = false;
  bool _onboardingComplete = true; // assume true until checked
  String? _authInfoMessage;
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _analyticsService.endSession();
    _connectivityService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _analyticsService.startSession();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _analyticsService.endSession();
        break;
      default:
        break;
    }
  }

  Future<void> _bootstrap() async {
    _connectivityService.start();
    _analyticsService.startSession();
    final prefs = await SharedPreferences.getInstance();
    final onboarded = prefs.getBool('onboardingComplete') ?? false;
    await _authRepository.restoreSession();
    if (!mounted) return;
    setState(() {
      _onboardingComplete = onboarded;
      _ready = true;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);
    if (!mounted) return;
    setState(() {
      _onboardingComplete = true;
    });
  }

  Future<void> _login(String email, String password) async {
    await _authRepository.login(email: email, password: password);
    if (!mounted) return;
    setState(() {
      _authInfoMessage = null;
    });
  }

  Future<void> _register(String email, String password) async {
    await _authRepository.registerAndLogin(email: email, password: password);
    if (!mounted) return;
    setState(() {
      _authInfoMessage = null;
    });
  }

  Future<void> _logout() async {
    await _authRepository.logout();
    if (!mounted) return;
    // Delay UI swap to next frame so disposed widget's inherited
    // dependencies are fully cleaned up first.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _handleSessionExpired(String message) async {
    await _authRepository.logout();
    if (!mounted) return;
    // Delay UI swap to next frame so disposed widget's inherited
    // dependencies are fully cleaned up first.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _authInfoMessage = message;
        });
      }
    });
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget home;

    if (!_ready) {
      home = const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else if (!_onboardingComplete) {
      home = OnboardingScreen(onComplete: _completeOnboarding);
    } else if (_authRepository.isAuthenticated) {
      home = SanctumScreen(
        authRepository: _authRepository,
        habitRepository: _habitRepository,
        onLogout: _logout,
        onSessionExpired: _handleSessionExpired,
        themeMode: _themeMode,
        onToggleTheme: _toggleTheme,
        connectivityService: _connectivityService,
        analyticsService: _analyticsService,
        streakService: _streakService,
        achievementService: _achievementService,
        weeklyLogService: _weeklyLogService,
      );
    } else {
      home = AuthScreen(
        onLogin: _login,
        onRegister: _register,
        infoMessage: _authInfoMessage,
        themeMode: _themeMode,
        onToggleTheme: _toggleTheme,
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rise',
      themeMode: _themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: home,
    );
  }
}

