import 'package:flutter/material.dart';

/// Minimal Glassmorphism color palette.
class AppColors {
  AppColors._();

  // Background
  static const Color background = Color(0xFFF5F6FA);
  static const Color backgroundSecondary = Color(0xFFECEEF5);

  // Accents
  static const Color primary = Color(0xFF6C8EE3); // Muted blue
  static const Color primaryLight = Color(0xFF8FA9EC);
  static const Color primaryDark = Color(0xFF5173C7);

  static const Color secondary = Color(0xFFA99BEA); // Soft lavender
  static const Color secondaryLight = Color(0xFFC4BAF2);
  static const Color secondaryDark = Color(0xFF8F7ED8);

  // Glass surfaces
  static const Color glassWhite = Color(0xD9FFFFFF); // 85% opacity
  static const Color glassWhiteElevated = Color(0xEEFFFFFF); // 93% opacity
  static const Color glassWhiteSubtle = Color(0x80FFFFFF); // 50% opacity
  static const Color glassBorder = Color(0x66FFFFFF); // 40% white border
  static const Color glassBorderSubtle = Color(
    0x1F25283B,
  ); // 12% charcoal border

  // Text & Neutrals
  static const Color textPrimary = Color(0xFF25283B); // Dark charcoal
  static const Color textSecondary = Color(0xFF85899A); // Muted gray
  static const Color textMuted = Color(0xFFA6AAB8); // Light gray
  static const Color divider = Color(0x1425283B); // 8% charcoal

  // Status & Feedback
  static const Color success = Color(0xFF5EAA8D); // Soft sage green
  static const Color successSurface = Color(0x1F5EAA8D);

  static const Color warning = Color(0xFFE5A84B); // Muted amber
  static const Color warningSurface = Color(0x1FE5A84B);

  static const Color danger = Color(0xFFE86B6B); // Soft coral red
  static const Color dangerSurface = Color(0x1FE86B6B);

  static const Color info = Color(0xFF6C8EE3);
  static const Color infoSurface = Color(0x1F6C8EE3);
}
