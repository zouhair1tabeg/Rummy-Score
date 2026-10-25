import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Provides a minimal ambient pastel gradient background that enables
/// authentic glassmorphic translucency across screens.
class GlassBackground extends StatelessWidget {
  final Widget child;

  const GlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        gradient: RadialGradient(
          center: Alignment(0.8, -0.6),
          radius: 1.2,
          colors: [
            Color(0x18A99BEA), // Soft lavender glow (subtle)
            Color(0x106C8EE3), // Soft blue tint
            AppColors.background,
          ],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Gentle ambient spot at bottom left
          Positioned(
            bottom: -80,
            left: -80,
            width: 260,
            height: 260,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.06),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
