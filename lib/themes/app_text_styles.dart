import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Use Outfit for headings (modern, geometric) and Inter for body text (highly readable)
  
  static TextTheme getTextTheme(BuildContext context, ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: GoogleFonts.outfit(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: colorScheme.onSurface,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      displaySmall: GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      headlineLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      headlineSmall: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: colorScheme.onSurface,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: colorScheme.onSurface,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: colorScheme.onSurface,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: colorScheme.onSurface,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: colorScheme.onSurface,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: colorScheme.onSurface,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: colorScheme.onSurface,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: colorScheme.onSurface,
      ),
    );
  }
}
