import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// App-wide ThemeData builder.
abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: AppColors.background(isDark),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
      ),
    );

    return base.copyWith(
      // ── Text ────────────────────────────────────────────────────────
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.text(isDark),
        displayColor: AppColors.text(isDark),
      ),

      // ── AppBar ──────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.heading(isDark),
        ),
        iconTheme: IconThemeData(color: AppColors.icon(isDark)),
      ),

      // ── FilledButton ────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.md),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.md,
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // ── TextButton ──────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // ── Input ───────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? AppColors.darkCard.withValues(alpha: 0.35)
            : AppColors.lightCard.withValues(alpha: 0.50),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
          borderSide: BorderSide(color: AppColors.glassBorder(isDark)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
          borderSide: BorderSide(color: AppColors.glassBorder(isDark)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: TextStyle(color: AppColors.textSecondary(isDark)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),

      // ── Card ────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surface(isDark),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
      ),

      // ── Dropdown ────────────────────────────────────────────────────
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(color: AppColors.text(isDark)),
      ),
    );
  }
}
