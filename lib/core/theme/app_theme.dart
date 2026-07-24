import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final colorScheme = _lightColorScheme();
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      scaffoldBackgroundColor: AppColors.neutral50,
      inputDecorationTheme: _inputDecoration(colorScheme),
      appBarTheme: _appBar(colorScheme),
      cardTheme: _card(colorScheme),
      filledButtonTheme: _filledButton(colorScheme),
      outlinedButtonTheme: _outlinedButton(colorScheme),
      navigationBarTheme: _navigationBar(colorScheme),
    );
  }

  static ThemeData dark() {
    final colorScheme = _darkColorScheme();
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ),
      scaffoldBackgroundColor: AppColors.navy900,
      inputDecorationTheme: _inputDecoration(colorScheme),
      appBarTheme: _appBar(colorScheme),
      cardTheme: _card(colorScheme),
      filledButtonTheme: _filledButton(colorScheme),
      outlinedButtonTheme: _outlinedButton(colorScheme),
      navigationBarTheme: _navigationBar(colorScheme),
    );
  }

  static ColorScheme _lightColorScheme() => const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.teal400,
        onPrimary: Colors.white,
        primaryContainer: AppColors.teal50,
        onPrimaryContainer: AppColors.navy900,
        secondary: AppColors.navy400,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.navy50,
        onSecondaryContainer: AppColors.navy900,
        tertiary: AppColors.teal200,
        onTertiary: AppColors.navy900,
        tertiaryContainer: AppColors.teal50,
        onTertiaryContainer: AppColors.navy900,
        error: AppColors.expense,
        onError: Colors.white,
        errorContainer: Color(0xFFFFDAD6),
        onErrorContainer: Color(0xFF93000A),
        surface: Colors.white,
        onSurface: AppColors.neutral900,
        surfaceContainerHighest: AppColors.neutral100,
        onSurfaceVariant: AppColors.neutral600,
        outline: AppColors.neutral200,
        outlineVariant: AppColors.neutral100,
        inverseSurface: AppColors.navy900,
        onInverseSurface: Colors.white,
        inversePrimary: AppColors.teal200,
        scrim: AppColors.navy900,
        shadow: AppColors.navy900,
      );

  static ColorScheme _darkColorScheme() => const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.teal400,
        onPrimary: Colors.white,
        primaryContainer: AppColors.navy800,
        onPrimaryContainer: AppColors.teal100,
        secondary: AppColors.navy400,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.navy800,
        onSecondaryContainer: AppColors.navy100,
        tertiary: AppColors.teal200,
        onTertiary: AppColors.navy900,
        tertiaryContainer: AppColors.navy800,
        onTertiaryContainer: AppColors.teal100,
        error: AppColors.expense,
        onError: Colors.white,
        errorContainer: Color(0xFF93000A),
        onErrorContainer: Color(0xFFFFDAD6),
        surface: AppColors.navy900,
        onSurface: Colors.white,
        surfaceContainerHighest: AppColors.navy800,
        onSurfaceVariant: AppColors.navy200,
        outline: AppColors.navy600,
        outlineVariant: AppColors.navy800,
        inverseSurface: AppColors.neutral50,
        onInverseSurface: AppColors.neutral900,
        inversePrimary: AppColors.teal400,
        scrim: Colors.black,
        shadow: Colors.black,
      );

  static AppBarTheme _appBar(ColorScheme cs) => AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: cs.onSurface,
        ),
      );

  static CardThemeData _card(ColorScheme cs) => CardThemeData(
        color: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cs.outlineVariant),
        ),
      );

  static FilledButtonThemeData _filledButton(ColorScheme cs) =>
      FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.teal400,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  static OutlinedButtonThemeData _outlinedButton(ColorScheme cs) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy400,
          minimumSize: const Size(0, 48),
          side: const BorderSide(color: AppColors.navy400),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  static InputDecorationTheme _inputDecoration(ColorScheme cs) =>
      InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      );

  static NavigationBarThemeData _navigationBar(ColorScheme cs) =>
      NavigationBarThemeData(
        backgroundColor: cs.surface,
        indicatorColor: AppColors.teal50,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.teal400);
          }
          return IconThemeData(color: cs.onSurfaceVariant);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final base = GoogleFonts.plusJakartaSans(fontSize: 12);
          if (states.contains(WidgetState.selected)) {
            return base.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.teal400,
            );
          }
          return base.copyWith(color: cs.onSurfaceVariant);
        }),
      );
}
