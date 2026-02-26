import 'package:flutter/material.dart';

/// Centralized color tokens for Rise.
/// All widgets and screens must reference these instead of inline Color values.
abstract final class AppColors {
  // ── Brand / Primary ───────────────────────────────────────────────
  static const Color primary = Color(0xFF2E79FF);
  static const Color primaryLight = Color(0xFF2490FF);
  static const Color accent = Color(0xFF4BC8FF);

  // ── XP Categories ─────────────────────────────────────────────────
  static const Color chakra = Color(0xFF5D63F3);
  static const Color vitality = Color(0xFFF4A11A);
  static const Color focus = Color(0xFF2E88F7);

  // ── Semantic ──────────────────────────────────────────────────────
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ── Dark theme ────────────────────────────────────────────────────
  static const Color darkBg = Color(0xFF0D111B);
  static const Color darkSurface = Color(0xFF101827);
  static const Color darkCard = Color(0xFF202A44);
  static const Color darkCardSecondary = Color(0xFF111A2D);
  static const Color darkText = Color(0xFFE6ECFF);
  static const Color darkTextSecondary = Color(0xFFA8B7D4);
  static const Color darkTextTertiary = Color(0xFF9EB0D0);
  static const Color darkTextMuted = Color(0xFF95A8C9);
  static const Color darkIcon = Color(0xFF7E91B4);
  static const Color darkBorder = Color(0xFF233253);
  static const Color darkGradientStart = Color(0xFF090F1F);
  static const Color darkGradientMid = Color(0xFF0D1730);
  static const Color darkGradientEnd = Color(0xFF0A1224);
  static const Color darkProgressBg = Color(0xFF1D2945);
  static const Color darkHeaderBgStart = Color(0xFF141A2E);
  static const Color darkHeaderBgEnd = Color(0xFF0D0F1A);

  // ── Light theme ───────────────────────────────────────────────────
  static const Color lightBg = Color(0xFFF2F4F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFEAF0FA);
  static const Color lightText = Color(0xFF101A33);
  static const Color lightTextSecondary = Color(0xFF4A5A72);
  static const Color lightTextTertiary = Color(0xFF6B7F9D);
  static const Color lightTextMuted = Color(0xFF697E9C);
  static const Color lightTextHeading = Color(0xFF0F1B36);
  static const Color lightIcon = Color(0xFF63789A);
  static const Color lightBorder = Color(0xFFD9E4F8);
  static const Color lightGradientStart = Color(0xFFEFF4FF);
  static const Color lightGradientMid = Color(0xFFF8FAFF);
  static const Color lightGradientEnd = Color(0xFFE8F0FF);

  // ── Glass card helpers ────────────────────────────────────────────
  static Color glassOverlay(bool isDark) =>
      isDark ? darkCard.withValues(alpha: 0.38) : lightSurface.withValues(alpha: 0.44);

  static Color glassOverlaySecondary(bool isDark) =>
      isDark ? darkCardSecondary.withValues(alpha: 0.25) : lightCard.withValues(alpha: 0.28);

  static Color glassBorder(bool isDark) =>
      isDark ? Colors.white.withValues(alpha: 0.14) : lightBorder.withValues(alpha: 0.65);

  static Color glassShadow(bool isDark) =>
      isDark ? Colors.black.withValues(alpha: 0.40) : const Color(0xFF92A7CB).withValues(alpha: 0.20);

  // ── Helpers ───────────────────────────────────────────────────────
  static Color text(bool isDark) => isDark ? darkText : lightText;
  static Color textSecondary(bool isDark) => isDark ? darkTextSecondary : lightTextSecondary;
  static Color textTertiary(bool isDark) => isDark ? darkTextTertiary : lightTextTertiary;
  static Color textMuted(bool isDark) => isDark ? darkTextMuted : lightTextMuted;
  static Color heading(bool isDark) => isDark ? Colors.white : lightTextHeading;
  static Color icon(bool isDark) => isDark ? darkIcon : lightIcon;
  static Color background(bool isDark) => isDark ? darkBg : lightBg;
  static Color surface(bool isDark) => isDark ? darkSurface : lightSurface;

  static List<Color> bgGradient(bool isDark) => isDark
      ? const [darkGradientStart, darkGradientMid, darkGradientEnd]
      : const [lightGradientStart, lightGradientMid, lightGradientEnd];

  static Color orbGlow(bool isDark) =>
      primary.withValues(alpha: isDark ? 0.24 : 0.16);

  static Color orbGlowSecondary(bool isDark) =>
      accent.withValues(alpha: isDark ? 0.16 : 0.12);
}
