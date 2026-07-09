import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_mobile/core/utils/route_transition.dart';

class AppTheme {
  AppTheme._();

  // ──────────────────────────────────────────────
  //  BRAND COLORS
  // ──────────────────────────────────────────────
  static const Color primaryNavy = Color(0xFF00236F);
  static const Color secondaryBlue = Color(0xFF0058BE);
  static const Color primaryOrange = primaryNavy;
  static const Color primaryOrangeLight = secondaryBlue;
  static const Color primaryOrangeDark = primaryNavy;

  // Light Palette
  static const Color _lightBg = Color(0xFFF8F9FF);
  static const Color _lightSurface = Colors.white;
  static const Color _lightCard = Colors.white;
  static const Color _lightTextPrimary = Color(0xFF0B1C30);
  static const Color _lightTextSecondary = Color(0xFF444651);
  static const Color _lightBorder = Color(0xFFC5C5D3);
  static const Color _lightInputFill = Color(0xFFEFF4FF);

  // Dark Palette
  static const Color _darkBg = Color(0xFF0F172A);
  static const Color _darkSurface = Color(0xFF1E293B);
  static const Color _darkCard = Color(0xFF1E293B);
  static const Color _darkTextPrimary = Color(0xFFF8F9FF);
  static const Color _darkTextSecondary = Color(0xFFC5C5D3);
  static const Color _darkBorder = Color(0xFF444651);
  static const Color _darkInputFill = Color(0xFF1E293B);

  // Status Colors
  static const Color statusOpen = Color(0xFFEF4444);
  static const Color statusAssigned = Color(0xFFF59E0B);
  static const Color statusInProgress = Color(0xFF3B82F6);
  static const Color statusClosed = Color(0xFF10B981);

  // Priority Colors
  static const Color priorityLow = Color(0xFF3B82F6);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityHigh = Color(0xFFEF4444);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryNavy, secondaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkHeaderGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ──────────────────────────────────────────────
  //  SHARED TEXT THEME (Hanken Grotesk & Inter & JetBrains Mono)
  // ──────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: GoogleFonts.hankenGrotesk(color: primary, fontWeight: FontWeight.w800, fontSize: 32),
      displayMedium: GoogleFonts.hankenGrotesk(color: primary, fontWeight: FontWeight.w700, fontSize: 28),
      displaySmall: GoogleFonts.hankenGrotesk(color: primary, fontWeight: FontWeight.w700, fontSize: 24),
      headlineLarge: GoogleFonts.hankenGrotesk(color: primary, fontWeight: FontWeight.w700, fontSize: 22),
      headlineMedium: GoogleFonts.hankenGrotesk(color: primary, fontWeight: FontWeight.w700, fontSize: 20),
      headlineSmall: GoogleFonts.hankenGrotesk(color: primary, fontWeight: FontWeight.w600, fontSize: 18),
      titleLarge: GoogleFonts.hankenGrotesk(color: primary, fontWeight: FontWeight.w700, fontSize: 18),
      titleMedium: GoogleFonts.hankenGrotesk(color: primary, fontWeight: FontWeight.w600, fontSize: 16),
      titleSmall: GoogleFonts.hankenGrotesk(color: primary, fontWeight: FontWeight.w600, fontSize: 14),
      bodyLarge: GoogleFonts.inter(color: primary, fontWeight: FontWeight.w400, fontSize: 16),
      bodyMedium: GoogleFonts.inter(color: secondary, fontWeight: FontWeight.w400, fontSize: 14),
      bodySmall: GoogleFonts.inter(color: secondary, fontWeight: FontWeight.w400, fontSize: 12),
      labelLarge: GoogleFonts.jetBrainsMono(color: primary, fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.05),
      labelMedium: GoogleFonts.jetBrainsMono(color: secondary, fontWeight: FontWeight.w500, fontSize: 12, letterSpacing: 0.05),
      labelSmall: GoogleFonts.jetBrainsMono(color: secondary, fontWeight: FontWeight.w500, fontSize: 10, letterSpacing: 0.05),
    );
  }

  // ──────────────────────────────────────────────
  //  1. LIGHT THEME
  // ──────────────────────────────────────────────
  static ThemeData get lightTheme {
    final textTheme = _buildTextTheme(_lightTextPrimary, _lightTextSecondary);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: SmoothPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: SmoothPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: SmoothPageTransitionsBuilder(),
        },
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryNavy,
        secondary: secondaryBlue,
        surface: _lightSurface,
        onPrimary: Colors.white,
        onSurface: _lightTextPrimary,
        outline: _lightBorder,
      ),
      scaffoldBackgroundColor: _lightBg,
      textTheme: textTheme,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: _lightSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: _lightTextPrimary, size: 22),
        titleTextStyle: GoogleFonts.hankenGrotesk(
          color: _lightTextPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(0, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryOrange,
          side: const BorderSide(color: primaryOrange, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryOrange,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: _lightCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _lightBorder, width: 1),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightInputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryOrange, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: statusOpen, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: statusOpen, width: 1.8),
        ),
        hintStyle: GoogleFonts.inter(color: const Color(0xFFAEB5C0), fontSize: 14),
        labelStyle: GoogleFonts.inter(color: _lightTextSecondary, fontSize: 14),
        prefixIconColor: _lightTextSecondary,
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _lightSurface,
        selectedItemColor: primaryOrange,
        unselectedItemColor: const Color(0xFFAEB5C0),
        selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        backgroundColor: _lightSurface,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: _lightSurface,
        titleTextStyle: GoogleFonts.hankenGrotesk(
          color: _lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: const Color(0xFF1E293B),
        contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 13),
      ),

      // ListTile (fix invisible ink splashes)
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        iconColor: _lightTextSecondary,
        textColor: _lightTextPrimary,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: _lightBorder,
        thickness: 0.8,
        space: 0,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: _lightInputFill,
        selectedColor: primaryOrange,
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: const BorderSide(color: _lightBorder),
      ),

      // Tab Bar
      tabBarTheme: TabBarThemeData(
        labelColor: primaryOrange,
        unselectedLabelColor: _lightTextSecondary,
        indicatorColor: primaryOrange,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 13),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryOrange;
          return const Color(0xFFCBD5E1);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryOrange.withValues(alpha: 0.35);
          return const Color(0xFFE2E8F0);
        }),
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  2. DARK THEME
  // ──────────────────────────────────────────────
  static ThemeData get darkTheme {
    final textTheme = _buildTextTheme(_darkTextPrimary, _darkTextSecondary);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: SmoothPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: SmoothPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: SmoothPageTransitionsBuilder(),
        },
      ),
      colorScheme: const ColorScheme.dark(
        primary: primaryOrange,
        secondary: primaryOrangeLight,
        surface: _darkSurface,
        onPrimary: Colors.white,
        onSurface: _darkTextPrimary,
        outline: _darkBorder,
      ),
      scaffoldBackgroundColor: _darkBg,
      textTheme: textTheme,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: _darkSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: _darkTextPrimary, size: 22),
        titleTextStyle: GoogleFonts.hankenGrotesk(
          color: _darkTextPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(0, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryOrange,
          side: const BorderSide(color: primaryOrange, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryOrange,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: _darkCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _darkBorder, width: 1),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkInputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryOrange, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: statusOpen, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: statusOpen, width: 1.8),
        ),
        hintStyle: GoogleFonts.inter(color: const Color(0xFF4A5568), fontSize: 14),
        labelStyle: GoogleFonts.inter(color: _darkTextSecondary, fontSize: 14),
        prefixIconColor: _darkTextSecondary,
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _darkSurface,
        selectedItemColor: primaryOrange,
        unselectedItemColor: const Color(0xFF4A5568),
        selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        backgroundColor: _darkCard,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: _darkCard,
        titleTextStyle: GoogleFonts.hankenGrotesk(
          color: _darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: const Color(0xFF334155),
        contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 13),
      ),

      // ListTile (fix invisible ink splashes)
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        iconColor: _darkTextSecondary,
        textColor: _darkTextPrimary,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: _darkBorder,
        thickness: 0.8,
        space: 0,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: _darkInputFill,
        selectedColor: primaryOrange,
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: const BorderSide(color: _darkBorder),
      ),

      // Tab Bar
      tabBarTheme: TabBarThemeData(
        labelColor: primaryOrange,
        unselectedLabelColor: _darkTextSecondary,
        indicatorColor: primaryOrange,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 13),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryOrange;
          return const Color(0xFF4A5568);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryOrange.withValues(alpha: 0.35);
          return const Color(0xFF30363D);
        }),
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  HELPER: Get adaptive colors based on brightness
  // ──────────────────────────────────────────────
  static Color cardColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _darkCard : _lightCard;

  static Color surfaceColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _darkSurface : _lightSurface;

  static Color borderColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _darkBorder : _lightBorder;

  static Color inputFillColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _darkInputFill : _lightInputFill;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _darkTextPrimary : _lightTextPrimary;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _darkTextSecondary : _lightTextSecondary;
}