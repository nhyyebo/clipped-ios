import 'package:flutter/material.dart';

class AppColors {
  // Velvety Black Backgrounds
  static const Color primaryBlack = Color(0xFF000000);
  static const Color richBlack = Color(0xFF0A0A0A);
  static const Color velvetBlack = Color(0xFF1A1A1A);
  static const Color deepCharcoal = Color(0xFF1C1C1E);
  static const Color softCharcoal = Color(0xFF2C2C2E);
  
  // Card Surfaces with depth
  static const Color cardSurface = Color(0xFF1E1E20);
  static const Color cardElevated = Color(0xFF252528);
  static const Color cardPressed = Color(0xFF2A2A2D);
  
  // Accent Colors
  static const Color iosBlue = Color(0xFF007AFF);
  static const Color iosBlueLight = Color(0xFF40A6FF);
  static const Color iosGreen = Color(0xFF34C759);
  static const Color iosRed = Color(0xFFFF3B30);
  static const Color iosOrange = Color(0xFFFF9500);
  static const Color iosPurple = Color(0xFFAF52DE);
  static const Color iosPink = Color(0xFFFF2D92);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFE5E5E7);
  static const Color textTertiary = Color(0xFFAEAEB2);
  static const Color textQuaternary = Color(0xFF8E8E93);
  static const Color textDisabled = Color(0xFF636366);
  
  // Border & Separator Colors
  static const Color separatorOpaque = Color(0xFF38383A);
  static const Color separatorNonOpaque = Color(0x4D8E8E93);
  static const Color borderSubtle = Color(0xFF48484A);
  
  // Glass morphism effect colors
  static const Color glassOverlay = Color(0x1AFFFFFF);
  static const Color glassBlur = Color(0x0DFFFFFF);
  
  // Gradients for enhanced depth
  static const LinearGradient velvetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A1A1A),
      Color(0xFF0A0A0A),
      Color(0xFF000000),
    ],
    stops: [0.0, 0.6, 1.0],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF252528),
      Color(0xFF1E1E20),
      Color(0xFF1A1A1C),
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  static const LinearGradient shimmerGradient = LinearGradient(
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
    colors: [
      Color(0x00FFFFFF),
      Color(0x1AFFFFFF),
      Color(0x00FFFFFF),
    ],
  );
  
  // Semantic colors
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);
  static const Color info = Color(0xFF007AFF);
  
  // Type-specific colors for different content types
  static const Color typeText = Color(0xFF8E8E93);
  static const Color typeUrl = Color(0xFF007AFF);
  static const Color typeEmail = Color(0xFFFF9500);
  static const Color typePhone = Color(0xFF34C759);
  static const Color typeImage = Color(0xFFAF52DE);
  static const Color typeDocument = Color(0xFFFF2D92);
} 