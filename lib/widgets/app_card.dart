import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Border? border;
  final double borderRadius;
  final bool isHighlight;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.border,
    this.borderRadius = 16,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorder =
        border ??
        Border.all(
          color: isHighlight
              ? AppColors.gold.withValues(alpha: 0.6)
              : AppColors.border,
          width: isHighlight ? 1.5 : 1.0,
        );

    final cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            (isHighlight ? AppColors.surfaceElevated : AppColors.surface),
        borderRadius: BorderRadius.circular(borderRadius),
        border: effectiveBorder,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          if (isHighlight)
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Container(
        margin: margin,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          child: InkWell(
            borderRadius: BorderRadius.circular(borderRadius),
            onTap: onTap,
            child: cardContent,
          ),
        ),
      );
    }

    return Container(margin: margin, child: cardContent);
  }
}
