import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/animations/tap_scale.dart';

/// 4-screen onboarding shown on first launch.
/// Persists completion via a callback — the caller handles SharedPreferences.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      icon: Icons.shield_rounded,
      gradient: [Color(0xFF2E79FF), Color(0xFF4BC8FF)],
      title: 'Welcome to Rise',
      body: 'Your personal sanctuary for building powerful daily habits, '
          'tracking progress, and levelling up your life.',
    ),
    _OnboardingPage(
      icon: Icons.auto_stories_rounded,
      gradient: [Color(0xFF5D63F3), Color(0xFF9F7AFF)],
      title: 'Track Daily Quests',
      body: 'Habits are grouped into Chakra, Vitality, and Focus. '
          'Complete them to earn XP in each category and rise through the ranks.',
    ),
    _OnboardingPage(
      icon: Icons.local_fire_department_rounded,
      gradient: [Color(0xFFFF6B35), Color(0xFFFFAA33)],
      title: 'Build Your Streak',
      body: 'Return every day to keep your streak alive. '
          'The longer your streak, the more powerful your aura becomes.',
    ),
    _OnboardingPage(
      icon: Icons.emoji_events_rounded,
      gradient: [Color(0xFF22C55E), Color(0xFF4ADE80)],
      title: 'Return Daily',
      body: 'Consistency is the key to mastery. '
          'Small daily actions compound into extraordinary results. Ready?',
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.bgGradient(isDark),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: TextButton(
                    onPressed: widget.onComplete,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted(isDark),
                      ),
                    ),
                  ),
                ),
              ),

              // Pages
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return _buildPage(page, isDark, isFirst: index == 0);
                  },
                ),
              ),

              // Dots
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                      width: _currentPage == i ? 28 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: _currentPage == i
                            ? AppColors.primary
                            : AppColors.textMuted(isDark).withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              ),

              // Next / Get Started button
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.xxxl),
                child: TapScale(
                  onTap: _next,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isLastPage
                            ? [const Color(0xFF22C55E), const Color(0xFF4ADE80)]
                            : [AppColors.primary, AppColors.primaryLight],
                      ),
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        isLastPage ? 'Get Started' : 'Next',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page, bool isDark, {bool isFirst = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Gradient icon circle
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: page.gradient,
              ),
              boxShadow: [
                BoxShadow(
                  color: page.gradient.first.withValues(alpha: 0.4),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: isFirst
                ? Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/brand/app_logo.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : Icon(page.icon, color: Colors.white, size: 64),
          ),
          const SizedBox(height: AppSpacing.xxxl + 8),
          Text(
            page.title,
            style: AppTextStyles.h1(isDark),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            page.body,
            style: AppTextStyles.body(isDark).copyWith(height: 1.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Data class for a single onboarding page.
class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final List<Color> gradient;
  final String title;
  final String body;
}
