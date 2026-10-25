import 'package:flutter/material.dart';

/// "Brainrot" neon theme: deep purple night + electric magenta/lime.
/// Louder than CodeArena but still readable for kids.
class AppTheme {
  static const bg = Color(0xFF14091F);
  static const bgAlt = Color(0xFF1F0F30);
  static const card = Color(0xFF2A1545);
  static const cardEdge = Color(0xFF4A2A6E);
  static const accent = Color(0xFFFF4DDB); // electric magenta
  static const accent2 = Color(0xFFB6FF3D); // toxic lime
  static const accent3 = Color(0xFF4DC8FF); // cyan zap
  static const good = Color(0xFF4ADE80);
  static const bad = Color(0xFFFF6B6B);
  static const textHi = Color(0xFFFFF6FF);
  static const textLo = Color(0xFFB99BD4);

  static ThemeData get theme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: accent2,
          tertiary: accent3,
          surface: card,
          error: bad,
          onSurface: textHi,
        ),
        cardTheme: CardThemeData(
          color: card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: cardEdge),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: bgAlt,
          foregroundColor: textHi,
          elevation: 0,
          centerTitle: false,
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: card,
          contentTextStyle: TextStyle(color: textHi),
        ),
        dividerColor: cardEdge,
        // Hover a button = a short phrase saying what it does.
        tooltipTheme: TooltipThemeData(
          waitDuration: const Duration(milliseconds: 350),
          showDuration: const Duration(seconds: 3),
          preferBelow: true,
          textStyle: const TextStyle(
              color: textHi, fontSize: 13, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF3A1D5E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: accent.withValues(alpha: 0.7)),
          ),
        ),
        // Fat, always-visible scrollbar — easy to grab with a touchpad.
        scrollbarTheme: ScrollbarThemeData(
          thickness: WidgetStateProperty.all(12),
          radius: const Radius.circular(8),
          crossAxisMargin: 2,
          minThumbLength: 64,
          thumbColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.dragged) || s.contains(WidgetState.hovered)
                  ? accent
                  : accent.withValues(alpha: 0.55)),
          trackColor: WidgetStateProperty.all(cardEdge.withValues(alpha: 0.35)),
          trackBorderColor: WidgetStateProperty.all(Colors.transparent),
        ),
        useMaterial3: true,
      );
}
