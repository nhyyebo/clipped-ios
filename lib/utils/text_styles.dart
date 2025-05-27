import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTextStyles {
  static TextStyle get _baseStyle => GoogleFonts.inter();
  
  // Large titles
  static TextStyle get largeTitle => _baseStyle.copyWith(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.41,
  );
  
  // Titles
  static TextStyle get title1 => _baseStyle.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.36,
  );
  
  static TextStyle get title2 => _baseStyle.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.26,
  );
  
  static TextStyle get title3 => _baseStyle.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.45,
  );
  
  // Headlines
  static TextStyle get headline => _baseStyle.copyWith(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.43,
  );
  
  // Body text
  static TextStyle get body => _baseStyle.copyWith(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: -0.43,
  );
  
  static TextStyle get bodySecondary => body.copyWith(
    color: AppColors.textSecondary,
  );
  
  // Callout
  static TextStyle get callout => _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: -0.32,
  );
  
  static TextStyle get calloutSecondary => callout.copyWith(
    color: AppColors.textSecondary,
  );
  
  // Subhead
  static TextStyle get subhead => _baseStyle.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: -0.24,
  );
  
  static TextStyle get subheadSecondary => subhead.copyWith(
    color: AppColors.textSecondary,
  );
  
  // Footnote
  static TextStyle get footnote => _baseStyle.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: -0.08,
  );
  
  // Caption
  static TextStyle get caption1 => _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0,
  );
  
  static TextStyle get caption2 => _baseStyle.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0.07,
  );
  
  // Button styles
  static TextStyle get buttonLarge => _baseStyle.copyWith(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.accent,
    letterSpacing: -0.43,
  );
  
  static TextStyle get buttonMedium => _baseStyle.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.accent,
    letterSpacing: -0.24,
  );
  
  static TextStyle get buttonSmall => _baseStyle.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.accent,
    letterSpacing: -0.08,
  );
} 