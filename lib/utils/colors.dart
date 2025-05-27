import 'package:flutter/material.dart';

class AppColors {
  // Dark theme colors inspired by iOS
  static const Color primaryBackground = Color(0xFF000000);
  static const Color secondaryBackground = Color(0xFF1C1C1E);
  static const Color tertiaryBackground = Color(0xFF2C2C2E);
  
  // Card colors
  static const Color cardBackground = Color(0xFF2C2C2E);
  static const Color cardBackgroundElevated = Color(0xFF3A3A3C);
  
  // Accent colors
  static const Color accent = Color(0xFF007AFF); // iOS Blue
  static const Color accentSecondary = Color(0xFF5856D6); // iOS Purple
  static const Color success = Color(0xFF30D158); // iOS Green
  static const Color warning = Color(0xFFFF9F0A); // iOS Orange
  static const Color error = Color(0xFFFF453A); // iOS Red
  
  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary = Color(0xFF48484A);
  
  // Border and separator colors
  static const Color border = Color(0xFF38383A);
  static const Color separatorOpaque = Color(0xFF38383A);
  static const Color separatorNonOpaque = Color(0x33787880);
  
  // Interactive colors
  static const Color buttonBackground = Color(0xFF2C2C2E);
  static const Color buttonBackgroundPressed = Color(0xFF3A3A3C);
  
  // Gradient colors for cards
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2C2C2E),
      Color(0xFF1C1C1E),
    ],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF007AFF),
      Color(0xFF5856D6),
    ],
  );
} 