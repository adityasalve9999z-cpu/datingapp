import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// HeroUI-Inspired Design System for GlowDate
/// Semantic color roles, clean surfaces, electric-blue accent palette
/// ─────────────────────────────────────────────────────────────────────────────
class AppTheme {
  // ── Backgrounds ─────────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0A0A0B);   // zinc-950
  static const Color surfaceDark    = Color(0xFF18181B);   // zinc-900
  static const Color surfaceCard    = Color(0xFF27272A);   // zinc-800
  static const Color surfaceGlass   = Color(0x2227272A);   // 13% zinc-800

  // ── HeroUI Semantic Accent Colors ───────────────────────────────────────────
  static const Color primaryRose    = Color(0xFF006FEE);   // HeroUI "primary" electric blue
  static const Color primaryCoral   = Color(0xFF338EF7);   // HeroUI "primary-400" light blue
  static const Color primaryPurple  = Color(0xFF7828C8);   // HeroUI "secondary" violet
  static const Color accentCyan     = Color(0xFF00B7FA);   // HeroUI "primary-300" sky
  static const Color accentGold     = Color(0xFF006FEE);   // alias → primary blue
  static const Color emeraldGreen   = Color(0xFF17C964);   // HeroUI "success"
  static const Color warningAmber   = Color(0xFFF5A524);   // HeroUI "warning"
  static const Color dangerRose     = Color(0xFFF31260);   // HeroUI "danger"

  // ── Text ─────────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFECEDEE);   // zinc-100
  static const Color textSecondary = Color(0xFFA1A1AA);   // zinc-400
  static const Color textMuted     = Color(0xFF71717A);   // zinc-500

  // ── Border ───────────────────────────────────────────────────────────────────
  static const Color borderDefault = Color(0x26FFFFFF);   // white 15%
  static const Color borderFocus   = Color(0xFF006FEE);

  // ── Gradient Presets ─────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF006FEE), Color(0xFF338EF7)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFF006FEE), Color(0xFF7828C8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFF006FEE), Color(0xFF0057BB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient violetGradient = LinearGradient(
    colors: [Color(0xFF7828C8), Color(0xFF9353D3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardOverlayGradient = LinearGradient(
    colors: [
      Colors.transparent,
      Color(0x660A0A0B),
      Color(0xF10A0A0B),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x18FFFFFF),
      Color(0x04FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Material 3 ThemeData ─────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryRose,
        secondary: primaryPurple,
        surface: surfaceDark,
        onPrimary: Colors.white,
        onSurface: textPrimary,
        error: dangerRose,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderDefault, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceCard,
        selectedColor: Color(0x2F006FEE),
        labelStyle: const TextStyle(
            color: textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderDefault),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryRose,
        inactiveTrackColor: Colors.white10,
        thumbColor: Colors.white,
        overlayColor: const Color(0x2F006FEE),
        trackHeight: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceCard,
        hintStyle: const TextStyle(color: textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderFocus, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRose,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceCard,
        contentTextStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderDefault),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Helper: Glassmorphic Container ────────────────────────────────────────────
  static Widget glassContainer({
    required Widget child,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double blur = 16.0,
    Color border = borderDefault,
  }) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: -5,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: glassGradient,
              borderRadius: borderRadius ?? BorderRadius.circular(16),
              border: Border.all(color: border, width: 1.0),
              color: surfaceDark.withOpacity(0.5),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  // ── Helper: HeroUI-style Chip Container ───────────────────────────────────────
  static Widget heroBadge({
    required String label,
    Color? color,
    IconData? icon,
  }) {
    final c = color ?? primaryRose;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: c),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: c,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── MBTI color helper ─────────────────────────────────────────────────────────
  static Color mbtiColor(String mbti) {
    const analysts  = ['INTJ', 'INTP', 'ENTJ', 'ENTP'];
    const diplomats = ['INFJ', 'INFP', 'ENFJ', 'ENFP'];
    const sentinels = ['ISTJ', 'ISFJ', 'ESTJ', 'ESFJ'];
    const explorers = ['ISTP', 'ISFP', 'ESTP', 'ESFP'];
    if (analysts.contains(mbti))  return primaryPurple;
    if (diplomats.contains(mbti)) return emeraldGreen;
    if (sentinels.contains(mbti)) return accentCyan;
    if (explorers.contains(mbti)) return warningAmber;
    return primaryRose;
  }

  /// Returns an icon for a given lifestyle field value
  static IconData lifestyleIcon(String category, String value) {
    switch (category) {
      case 'drinking':
        switch (value.toLowerCase()) {
          case 'never':
            return Icons.no_drinks_rounded;
          case 'socially':
            return Icons.wine_bar_rounded;
          default:
            return Icons.local_bar_rounded;
        }
      case 'smoking':
        return value.toLowerCase() == 'never'
            ? Icons.smoke_free_rounded
            : Icons.smoking_rooms_rounded;
      case 'exercise':
        switch (value.toLowerCase()) {
          case 'daily':
            return Icons.directions_run_rounded;
          case 'often':
            return Icons.fitness_center_rounded;
          case 'sometimes':
            return Icons.directions_walk_rounded;
          default:
            return Icons.weekend_rounded;
        }
      case 'pets':
        if (value.contains('Dog')) return Icons.pets_rounded;
        if (value.contains('Cat')) return Icons.catching_pokemon_rounded;
        if (value.contains('Plant')) return Icons.eco_rounded;
        if (value.contains('Has')) return Icons.cruelty_free_rounded;
        return Icons.block_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  /// Returns a color for a lifestyle value
  static Color lifestyleColor(String category, String value) {
    switch (category) {
      case 'drinking':
        if (value == 'Never')    return emeraldGreen;
        if (value == 'Socially') return accentCyan;
        return dangerRose;
      case 'smoking':
        return value == 'Never' ? emeraldGreen : dangerRose;
      case 'exercise':
        if (value == 'Daily')  return emeraldGreen;
        if (value == 'Often')  return accentCyan;
        return textSecondary;
      default:
        return primaryRose;
    }
  }
}
