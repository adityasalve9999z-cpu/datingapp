import 'dart:ui';
import 'package:flutter/material.dart';

class AppTheme {
  // Brand Color Palette — "Lume" Deep Midnight Plum & Champagne Gold
  static const Color darkBackground = Color(0xFF160D1C); // Near-black plum
  static const Color surfaceDark = Color(0xFF221328); // Card/field surface
  static const Color surfaceCard = Color(0xFF2A1830); // Lighter plum card
  static const Color surfaceGlass = Color(0x333A2740); // Glassmorphic overlay

  static const Color primaryRose = Color(0xFFE8A7A0); // Soft blush secondary
  static const Color primaryCoral =
      Color(0xFFE07A6B); // Warm error/coral highlight
  static const Color primaryPurple = Color(0xFF4A2E55); // Deep accent purple
  static const Color accentCyan = Color(0xFF72A6A6); // Muted soft teal/cyan
  static const Color accentGold = Color(0xFFD4A857); // Champagne gold accent
  static const Color emeraldGreen = Color(0xFF81B29A); // Muted sage green

  static const Color textPrimary = Color(0xFFF3EEE9);
  static const Color textSecondary = Color(0xFFA79AAE);
  static const Color textMuted = Color(0xFF6E6274);

  // Gradient Presets
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFD4A857), Color(0xFFC79340)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFD4A857), Color(0xFFE8A7A0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4A857), Color(0xFF8A7245)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardOverlayGradient = LinearGradient(
    colors: [
      Colors.transparent,
      Color(0x66160D1C),
      Color(0xF1160D1C),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x2BFFFFFF),
      Color(0x05FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Material 3 ThemeData
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: accentGold,
        secondary: primaryRose,
        surface: surfaceDark,
        onPrimary: darkBackground,
        onSurface: textPrimary,
      ),
      fontFamily: 'Roboto',
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF3A2740), width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceCard,
        selectedColor: accentGold.withOpacity(0.2),
        labelStyle: const TextStyle(
            color: textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF3A2740)),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accentGold,
        inactiveTrackColor: Colors.white10,
        thumbColor: Colors.white,
        overlayColor: accentGold.withOpacity(0.2),
        trackHeight: 4,
      ),
    );
  }

  // Helper for Glassmorphic Containers
  static Widget glassContainer({
    required Widget child,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double blur = 15.0,
    Color border = const Color(0xFF3A2740),
  }) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: glassGradient,
              borderRadius: borderRadius ?? BorderRadius.circular(24),
              border: Border.all(color: border, width: 1.2),
              color: surfaceDark.withOpacity(0.6),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Returns a color for a given MBTI type group
  static Color mbtiColor(String mbti) {
    const analysts = ['INTJ', 'INTP', 'ENTJ', 'ENTP'];
    const diplomats = ['INFJ', 'INFP', 'ENFJ', 'ENFP'];
    const sentinels = ['ISTJ', 'ISFJ', 'ESTJ', 'ESFJ'];
    const explorers = ['ISTP', 'ISFP', 'ESTP', 'ESFP'];
    if (analysts.contains(mbti)) return const Color(0xFF9D84B7); // plum purple
    if (diplomats.contains(mbti)) return emeraldGreen; // sage emerald
    if (sentinels.contains(mbti)) return accentCyan; // soft cyan
    if (explorers.contains(mbti)) return accentGold; // champagne gold
    return accentGold;
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
        if (value == 'Never') return emeraldGreen;
        if (value == 'Socially') return accentCyan;
        return primaryCoral;
      case 'smoking':
        return value == 'Never' ? emeraldGreen : primaryCoral;
      case 'exercise':
        if (value == 'Daily') return emeraldGreen;
        if (value == 'Often') return accentCyan;
        return textSecondary;
      default:
        return accentGold;
    }
  }
}
