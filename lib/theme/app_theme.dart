import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// LinkedIn-inspired palette (HireLink branding kept).
class HirelinkColors {
  static const Color primary = Color(0xFF0A66C2);
  static const Color primaryDark = Color(0xFF004182);
  static const Color accent = Color(0xFF057642);
  static const Color background = Color(0xFFF3F2EF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F2EF);
  static const Color border = Color(0xFFE0DFDC);
  static const Color textPrimary = Color(0xFF191919);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textMuted = Color(0xFF5E5E5E);
  static const Color glassOverlay = Color(0x80FFFFFF);
  static const Color success = Color(0xFF057642);
  static const Color warning = Color(0xFFB54708);
  static const Color primaryContainerLight = Color(0xFFE8F3FC);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A66C2), Color(0xFF004182)],
  );
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF057642), Color(0xFF004D2C)],
  );

  /// Dark mode (LinkedIn-like charcoal).
  static const Color darkScaffold = Color(0xFF1B1F23);
  static const Color darkSurface = Color(0xFF2D3339);
  static const Color darkBorder = Color(0xFF3D454D);
  static const Color darkOnSurface = Color(0xFFE8E6E3);
}

class AppTheme {
  static TextStyle _sourceSans({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    required Color color,
    double? height,
  }) {
    return GoogleFonts.sourceSans3(fontSize: fontSize, fontWeight: fontWeight, color: color, height: height);
  }

  static TextTheme _textTheme(Color baseColor) => TextTheme(
        headlineLarge: _sourceSans(fontSize: 30, fontWeight: FontWeight.w700, color: baseColor, height: 1.16),
        headlineMedium: _sourceSans(fontSize: 24, fontWeight: FontWeight.w700, color: baseColor, height: 1.2),
        headlineSmall: _sourceSans(fontSize: 20, fontWeight: FontWeight.w700, color: baseColor, height: 1.24),
        titleLarge: _sourceSans(fontSize: 18, fontWeight: FontWeight.w600, color: baseColor, height: 1.3),
        titleMedium: _sourceSans(fontSize: 16, fontWeight: FontWeight.w600, color: baseColor, height: 1.35),
        titleSmall: _sourceSans(fontSize: 14, fontWeight: FontWeight.w600, color: baseColor, height: 1.35),
        bodyLarge: _sourceSans(fontSize: 16, fontWeight: FontWeight.w400, color: baseColor, height: 1.5),
        bodyMedium: _sourceSans(fontSize: 14, fontWeight: FontWeight.w400, color: baseColor, height: 1.5),
        bodySmall: _sourceSans(fontSize: 12, fontWeight: FontWeight.w300, color: baseColor, height: 1.45),
        labelLarge: _sourceSans(fontSize: 14, fontWeight: FontWeight.w600, color: baseColor),
      );

  static ColorScheme get _lightColorScheme => ColorScheme.fromSeed(
        seedColor: HirelinkColors.primary,
        brightness: Brightness.light,
        surface: HirelinkColors.surface,
      ).copyWith(
        primary: HirelinkColors.primary,
        onPrimary: Colors.white,
        primaryContainer: HirelinkColors.primaryContainerLight,
        onPrimaryContainer: HirelinkColors.primaryDark,
        surface: HirelinkColors.surface,
        onSurface: HirelinkColors.textPrimary,
        onSurfaceVariant: HirelinkColors.textSecondary,
        outline: HirelinkColors.border,
        outlineVariant: HirelinkColors.border,
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: _lightColorScheme,
        textTheme: _textTheme(HirelinkColors.textPrimary),
        appBarTheme: AppBarTheme(
          backgroundColor: HirelinkColors.surface,
          foregroundColor: HirelinkColors.textPrimary,
          elevation: 0,
          centerTitle: false,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          titleTextStyle: _sourceSans(fontSize: 18, fontWeight: FontWeight.w600, color: HirelinkColors.textPrimary),
          iconTheme: const IconThemeData(color: HirelinkColors.textPrimary, size: 24),
        ),
        dividerTheme: const DividerThemeData(color: HirelinkColors.border, thickness: 1),
        cardTheme: CardThemeData(
          color: HirelinkColors.surface,
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: HirelinkColors.border, width: 1),
          ),
          surfaceTintColor: Colors.transparent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: HirelinkColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: HirelinkColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: HirelinkColors.primary,
            side: const BorderSide(color: HirelinkColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: HirelinkColors.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: HirelinkColors.border)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: HirelinkColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: HirelinkColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          hintStyle: _sourceSans(fontSize: 14, color: HirelinkColors.textMuted),
        ),
        scaffoldBackgroundColor: HirelinkColors.background,
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: HirelinkColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.transparent,
          indicatorColor: HirelinkColors.primary.withValues(alpha: 0.12),
          labelTextStyle: WidgetStateProperty.all(
            GoogleFonts.sourceSans3(fontSize: 11, fontWeight: FontWeight.w600, color: HirelinkColors.textMuted),
          ),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(size: 26, color: HirelinkColors.primary);
            }
            return const IconThemeData(size: 26, color: HirelinkColors.textMuted);
          }),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          height: 64,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: HirelinkColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: StadiumBorder(),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: HirelinkColors.primary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFF70B5F9),
          onPrimary: const Color(0xFF0A66C2),
          surface: HirelinkColors.darkSurface,
          onSurface: HirelinkColors.darkOnSurface,
          onSurfaceVariant: const Color(0xFFB0B0B0),
          outline: HirelinkColors.darkBorder,
          outlineVariant: HirelinkColors.darkBorder,
        ),
        scaffoldBackgroundColor: HirelinkColors.darkScaffold,
        textTheme: _textTheme(HirelinkColors.darkOnSurface),
        appBarTheme: AppBarTheme(
          backgroundColor: HirelinkColors.darkScaffold,
          foregroundColor: HirelinkColors.darkOnSurface,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: _sourceSans(fontSize: 18, fontWeight: FontWeight.w600, color: HirelinkColors.darkOnSurface),
        ),
        cardTheme: CardThemeData(
          color: HirelinkColors.darkSurface,
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: HirelinkColors.darkBorder, width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF70B5F9),
            foregroundColor: const Color(0xFF0A66C2),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF70B5F9),
            foregroundColor: const Color(0xFF0A66C2),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF70B5F9),
            side: const BorderSide(color: Color(0xFF70B5F9), width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: HirelinkColors.darkSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: HirelinkColors.darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF70B5F9), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: HirelinkColors.darkSurface,
          indicatorColor: const Color(0xFF70B5F9).withValues(alpha: 0.2),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(size: 26, color: Color(0xFF70B5F9));
            }
            return const IconThemeData(size: 26, color: Colors.white54);
          }),
          labelTextStyle: WidgetStateProperty.all(
            GoogleFonts.sourceSans3(fontSize: 11, fontWeight: FontWeight.w600, color: HirelinkColors.darkOnSurface),
          ),
          height: 64,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF70B5F9),
          foregroundColor: Color(0xFF0A66C2),
          elevation: 2,
          shape: StadiumBorder(),
        ),
      );

  static ButtonStyle gradientButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: HirelinkColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }
}
