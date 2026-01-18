import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Latin Font - Plus Jakarta Sans
  static TextStyle get headingLarge => GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.2,
      );

  static TextStyle get headingMedium => GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  static TextStyle get headingSmall => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.4,
      );

  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.5,
      );

  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get labelMedium => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.4,
      );

  static TextStyle get labelUppercase => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
        height: 1.4,
      );

  static TextStyle get caption => GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  // Arabic Font - Amiri
  static TextStyle get arabicLarge => GoogleFonts.amiri(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.6,
      );

  static TextStyle get arabicMedium => GoogleFonts.amiri(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        height: 1.6,
      );

  static TextStyle get arabicSmall => GoogleFonts.amiri(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.6,
      );

  static TextStyle get arabicCounter => GoogleFonts.amiri(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  // Counter Numbers
  static TextStyle get counterLarge => GoogleFonts.plusJakartaSans(
        fontSize: 64,
        fontWeight: FontWeight.w300,
        height: 1,
      );

  static TextStyle get counterMedium => GoogleFonts.plusJakartaSans(
        fontSize: 48,
        fontWeight: FontWeight.w300,
        height: 1,
      );

  static TextStyle get counterSmall => GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w300,
        height: 1,
      );

  static TextStyle get statNumber => GoogleFonts.plusJakartaSans(
        fontSize: 56,
        fontWeight: FontWeight.w300,
        height: 1,
      );

  // Navigation
  static TextStyle get navTitle => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 1.4,
      );

  static TextStyle get navLabel => GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  // Button
  static TextStyle get buttonLarge => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get buttonSmall => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );
}
