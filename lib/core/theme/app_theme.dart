import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color scheme for light theme - Premium Minimalist
  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF2563EB), // Blue 600
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFDBEAFE), // Blue 100
    onPrimaryContainer: Color(0xFF1E3A8A), // Blue 900
    secondary: Color(0xFF475569), // Slate 600
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFF1F5F9), // Slate 100
    onSecondaryContainer: Color(0xFF0F172A), // Slate 900
    tertiary: Color(0xFF0D9488), // Teal 600
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFCCFBF1), // Teal 100
    onTertiaryContainer: Color(0xFF134E4A), // Teal 900
    error: Color(0xFFE11D48), // Rose 600
    onError: Colors.white,
    errorContainer: Color(0xFFFFE4E6),
    onErrorContainer: Color(0xFF881337),
    surface: Colors.white,
    onSurface: Color(0xFF0F172A), // Slate 900
    surfaceContainerHighest: Color(0xFFF8FAFC), // Slate 50
    onSurfaceVariant: Color(0xFF475569), // Slate 600
    outline: Color(0xFFCBD5E1), // Slate 300
    outlineVariant: Color(0xFFE2E8F0), // Slate 200
    shadow: Color(0xFF0F172A),
    scrim: Color(0xFF0F172A),
    inverseSurface: Color(0xFF0F172A),
    onInverseSurface: Colors.white,
    inversePrimary: Color(0xFF93C5FD), // Blue 300
    surfaceTint: Color(0xFF2563EB),
  );

  // Dark theme - Premium Deep Dark
  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF3B82F6), // Blue 500
    onPrimary: Colors.white,
    primaryContainer: Color(0xFF1E3A8A), // Blue 900
    onPrimaryContainer: Color(0xFFDBEAFE), // Blue 100
    secondary: Color(0xFF94A3B8), // Slate 400
    onSecondary: Color(0xFF0F172A), // Slate 900
    secondaryContainer: Color(0xFF1E293B), // Slate 800
    onSecondaryContainer: Color(0xFFF1F5F9), // Slate 100
    tertiary: Color(0xFF2DD4BF), // Teal 400
    onTertiary: Color(0xFF134E4A), // Teal 900
    tertiaryContainer: Color(0xFF0F766E), // Teal 700
    onTertiaryContainer: Color(0xFFCCFBF1), // Teal 100
    error: Color(0xFFFB7185), // Rose 400
    onError: Color(0xFF881337),
    errorContainer: Color(0xFFBE123C),
    onErrorContainer: Color(0xFFFFE4E6),
    surface: Color(0xFF09090B), // Zinc 950 (Extremely Dark)
    onSurface: Color(0xFFF8FAFC), // Slate 50
    surfaceContainerHighest: Color(0xFF18181B), // Zinc 900
    onSurfaceVariant: Color(0xFF94A3B8), // Slate 400
    outline: Color(0xFF3F3F46), // Zinc 700
    outlineVariant: Color(0xFF27272A), // Zinc 800
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFFF8FAFC),
    onInverseSurface: Color(0xFF09090B),
    inversePrimary: Color(0xFF1D4ED8), // Blue 700
    surfaceTint: Color(0xFF3B82F6),
  );

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();
    return ThemeData(
      useMaterial3: true,
      colorScheme: _lightColorScheme,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Very light slate
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      extensions: const <ThemeExtension<dynamic>>[
        AppCardTheme(),
        AppButtonTheme(),
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          backgroundColor: _lightColorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(color: _lightColorScheme.outlineVariant, width: 1.5),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _lightColorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _lightColorScheme.error),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF94A3B8),
          fontWeight: FontWeight.w500,
        ),
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 57,
          fontWeight: FontWeight.w800,
          letterSpacing: -2.0,
          height: 1.12,
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
          height: 1.25,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          height: 1.3,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          height: 1.5,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.1,
          height: 1.5,
        ),
      ).apply(
        bodyColor: _lightColorScheme.onSurface,
        displayColor: _lightColorScheme.onSurface,
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();
    return ThemeData(
      useMaterial3: true,
      colorScheme: _darkColorScheme,
      scaffoldBackgroundColor: const Color(0xFF000000), // Pure Black background
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      extensions: const <ThemeExtension<dynamic>>[
        AppCardTheme(),
        AppButtonTheme(),
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF09090B),
        foregroundColor: const Color(0xFFF8FAFC),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFF8FAFC),
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF09090B),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          side: const BorderSide(color: Color(0xFF27272A), width: 1),
        ),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          backgroundColor: _darkColorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(color: _darkColorScheme.outlineVariant, width: 1.5),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF09090B),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF3F3F46)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF27272A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _darkColorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _darkColorScheme.error),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF71717A),
          fontWeight: FontWeight.w500,
        ),
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 57,
          fontWeight: FontWeight.w800,
          letterSpacing: -2.0,
          height: 1.12,
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
          height: 1.25,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          height: 1.3,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          height: 1.5,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.1,
          height: 1.5,
        ),
      ).apply(
        bodyColor: _darkColorScheme.onSurface,
        displayColor: _darkColorScheme.onSurface,
      ),
    );
  }
}

// Custom theme extensions for glassmorphism
class AppCardTheme extends ThemeExtension<AppCardTheme> {
  const AppCardTheme();

  @override
  AppCardTheme copyWith() => const AppCardTheme();

  @override
  AppCardTheme lerp(ThemeExtension<AppCardTheme>? other, double t) => this;
}

class AppButtonTheme extends ThemeExtension<AppButtonTheme> {
  const AppButtonTheme();

  @override
  AppButtonTheme copyWith() => const AppButtonTheme();

  @override
  AppButtonTheme lerp(ThemeExtension<AppButtonTheme>? other, double t) => this;
}
