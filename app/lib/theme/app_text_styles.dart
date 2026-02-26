import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typography tokens for Rise.
abstract final class AppTextStyles {
  // ── Headings ──────────────────────────────────────────────────────
  static TextStyle h1(bool isDark) => TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: AppColors.heading(isDark),
      );

  static TextStyle h2(bool isDark) => TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.heading(isDark),
      );

  static TextStyle h3(bool isDark) => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.heading(isDark),
      );

  // ── Display (large numbers / stats) ───────────────────────────────
  static TextStyle displayLarge(bool isDark) => TextStyle(
        fontSize: 56,
        fontWeight: FontWeight.w800,
        color: AppColors.heading(isDark),
      );

  static TextStyle displayUnit(bool isDark) => const TextStyle(
        fontSize: 44,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      );

  // ── Body ──────────────────────────────────────────────────────────
  static TextStyle body(bool isDark) => TextStyle(
        fontSize: 16,
        color: AppColors.text(isDark),
      );

  static TextStyle bodyLarge(bool isDark) => TextStyle(
        fontSize: 18,
        color: AppColors.text(isDark),
      );

  static TextStyle bodySmall(bool isDark) => TextStyle(
        fontSize: 15,
        color: AppColors.text(isDark),
      );

  // ── Labels ────────────────────────────────────────────────────────
  static TextStyle sectionLabel(bool isDark) => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
        color: AppColors.textTertiary(isDark),
      );

  static TextStyle subtitle(bool isDark) => TextStyle(
        fontSize: 16,
        fontStyle: FontStyle.italic,
        color: AppColors.textMuted(isDark),
      );

  static TextStyle caption(bool isDark) => TextStyle(
        fontSize: 16,
        color: AppColors.textSecondary(isDark),
      );

  // ── Card title / item title ───────────────────────────────────────
  static TextStyle cardTitle(bool isDark) => TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.heading(isDark),
      );

  static TextStyle cardSubtitle(bool isDark) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary(isDark),
      );

  static TextStyle cardTitleCompleted(bool isDark) => TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: isDark ? const Color(0xFFB9C3D6) : const Color(0xFF9CA8B8),
        decoration: TextDecoration.lineThrough,
      );

  // ── Rank / header subtitle ────────────────────────────────────────
  static TextStyle rank(bool isDark) => TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w800,
        color: isDark ? const Color(0xFFEAF0FF) : const Color(0xFF121B34),
      );

  static TextStyle headerSubtitle(bool isDark) => TextStyle(
        fontSize: 16,
        color: AppColors.textSecondary(isDark),
      );

  // ── XP line items ─────────────────────────────────────────────────
  static const TextStyle xpChakra = TextStyle(color: AppColors.chakra, fontSize: 18);
  static const TextStyle xpVitality = TextStyle(color: AppColors.vitality, fontSize: 18);
  static const TextStyle xpFocus = TextStyle(color: AppColors.focus, fontSize: 18);

  // ── Ascension label ───────────────────────────────────────────────
  static TextStyle ascensionTitle(bool isDark) => TextStyle(
        fontSize: 20,
        color: AppColors.textTertiary(isDark),
      );

  // ── Nav bar item ──────────────────────────────────────────────────
  static TextStyle navLabel({required bool active, required Color color}) => TextStyle(
        fontSize: 16,
        color: active ? AppColors.primary : color,
        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
      );

  // ── Tag / badge ───────────────────────────────────────────────────
  static TextStyle tag(Color accent) => TextStyle(
        color: accent,
        fontWeight: FontWeight.w800,
        fontSize: 18,
      );
}
