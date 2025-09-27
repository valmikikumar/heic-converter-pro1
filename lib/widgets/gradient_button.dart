import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.gradient,
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonGradient = gradient ?? AppTheme.primaryGradient;
    
    return Container(
      width: width,
      height: height ?? 48,
      decoration: BoxDecoration(
        gradient: onPressed != null ? buttonGradient : null,
        color: onPressed == null ? theme.colorScheme.outline.withOpacity(0.3) : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: onPressed != null ? [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: padding ?? const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: DefaultTextStyle(
                style: theme.textTheme.labelLarge?.copyWith(
                  color: onPressed != null ? Colors.white : theme.colorScheme.outline,
                  fontWeight: FontWeight.w600,
                ) ?? const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProGradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const ProGradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: width,
      height: height ?? 48,
      decoration: BoxDecoration(
        gradient: onPressed != null ? AppTheme.accentGradient : null,
        color: onPressed == null ? theme.colorScheme.outline.withOpacity(0.3) : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: onPressed != null ? [
          BoxShadow(
            color: AppTheme.accentOrange.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: padding ?? const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: DefaultTextStyle(
                style: theme.textTheme.labelLarge?.copyWith(
                  color: onPressed != null ? Colors.white : theme.colorScheme.outline,
                  fontWeight: FontWeight.w600,
                ) ?? const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
