import 'dart:ui';
import 'package:flutter/material.dart';

class AppTheme {
  // Brand Color Palette
  static const Color darkBackground = Color(0xFF0D0C13);
  static const Color surfaceDark = Color(0xFF181622);
  static const Color surfaceCard = Color(0xFF221F30);
  static const Color surfaceGlass = Color(0x33262335);
  
  static const Color primaryRose = Color(0xFFFF2A6D);
  static const Color primaryCoral = Color(0xFFFF6464);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color accentCyan = Color(0xFF05D5E4);
  static const Color accentGold = Color(0xFFFFB800);
  static const Color emeraldGreen = Color(0xFF10B981);
  
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  // Gradient Presets
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF2A6D), Color(0xFFFF6464)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFF2A6D), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardOverlayGradient = LinearGradient(
    colors: [
      Colors.transparent,
      Color(0x66000000),
      Color(0xF10B0914),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x3BFFFFFF),
      Color(0x0FFFFFFF),
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
        primary: primaryRose,
        secondary: primaryPurple,
        surface: surfaceDark,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      fontFamily: 'Roboto',
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
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
        selectedColor: primaryRose.withOpacity(0.2),
        labelStyle: const TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0x33FFFFFF)),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryRose,
        inactiveTrackColor: Colors.white10,
        thumbColor: Colors.white,
        overlayColor: primaryRose.withOpacity(0.2),
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
    Color border = const Color(0x2BFFFFFF),
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
    if (analysts.contains(mbti)) return const Color(0xFF8B5CF6);   // purple
    if (diplomats.contains(mbti)) return const Color(0xFF10B981);   // emerald
    if (sentinels.contains(mbti)) return const Color(0xFF3B82F6);   // blue
    if (explorers.contains(mbti)) return const Color(0xFFFFB800);   // gold
    return primaryRose;
  }

  /// Returns an icon for a given lifestyle field value
  static IconData lifestyleIcon(String category, String value) {
    switch (category) {
      case 'drinking':
        switch (value.toLowerCase()) {
          case 'never': return Icons.no_drinks_rounded;
          case 'socially': return Icons.wine_bar_rounded;
          default: return Icons.local_bar_rounded;
        }
      case 'smoking':
        return value.toLowerCase() == 'never'
            ? Icons.smoke_free_rounded
            : Icons.smoking_rooms_rounded;
      case 'exercise':
        switch (value.toLowerCase()) {
          case 'daily': return Icons.directions_run_rounded;
          case 'often': return Icons.fitness_center_rounded;
          case 'sometimes': return Icons.directions_walk_rounded;
          default: return Icons.weekend_rounded;
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
