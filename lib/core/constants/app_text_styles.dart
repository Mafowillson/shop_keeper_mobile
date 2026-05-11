import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Display styles - Playfair Display
  static TextStyle displayXL = GoogleFonts.playfairDisplay(
    fontSize: 36,
    fontWeight: FontWeight.w700,
  );

  static TextStyle displayL = GoogleFonts.playfairDisplay(
    fontSize: 28,
    fontWeight: FontWeight.w700,
  );

  static TextStyle displayM = GoogleFonts.playfairDisplay(
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );

  static TextStyle displayS = GoogleFonts.playfairDisplay(
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  // Heading styles - DM Sans
  static TextStyle headingL = GoogleFonts.dmSans(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static TextStyle headingM = GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static TextStyle headingS = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  // Body styles
  static TextStyle bodyL = GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodyM = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodyS = GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF666666),
  );

  // Label styles
  static TextStyle labelL = GoogleFonts.dmSans(
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static TextStyle labelM = GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  static TextStyle labelS = GoogleFonts.dmSans(
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );
}
