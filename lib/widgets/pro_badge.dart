import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ProBadge extends StatelessWidget {
  final bool isPro;
  final double? size;
  final Color? backgroundColor;
  final Color? textColor;

  const ProBadge({
    super.key,
    required this.isPro,
    this.size,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (size ?? 16) * 0.8,
        vertical: (size ?? 16) * 0.3,
      ),
      decoration: BoxDecoration(
        gradient: isPro ? AppTheme.accentGradient : null,
        color: isPro ? null : theme.colorScheme.outline.withOpacity(0.2),
        borderRadius: BorderRadius.circular((size ?? 16) * 0.5),
        border: isPro ? null : Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPro ? Icons.workspace_premium : Icons.free_breakfast,
            size: (size ?? 16) * 0.8,
            color: isPro 
                ? (textColor ?? Colors.white)
                : theme.colorScheme.outline,
          ),
          SizedBox(width: (size ?? 16) * 0.3),
          Text(
            isPro ? 'PRO' : 'FREE',
            style: TextStyle(
              color: isPro 
                  ? (textColor ?? Colors.white)
                  : theme.colorScheme.outline,
              fontWeight: FontWeight.bold,
              fontSize: (size ?? 16) * 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class ProFeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isLocked;

  const ProFeatureCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.onTap,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: isLocked ? 1 : 3,
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isLocked 
                ? theme.colorScheme.surfaceVariant.withOpacity(0.5)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isLocked 
                          ? theme.colorScheme.outline.withOpacity(0.2)
                          : AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isLocked ? Icons.lock : icon,
                      color: isLocked 
                          ? theme.colorScheme.outline
                          : AppTheme.primaryBlue,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  if (isLocked) const ProBadge(isPro: false, size: 12),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isLocked 
                      ? theme.colorScheme.outline
                      : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isLocked 
                      ? theme.colorScheme.outline.withOpacity(0.7)
                      : theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpgradePromptWidget extends StatelessWidget {
  final VoidCallback? onUpgrade;
  final String? title;
  final String? description;

  const UpgradePromptWidget({
    super.key,
    this.onUpgrade,
    this.title,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.accentGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentOrange.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.workspace_premium,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? 'Upgrade to Pro',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description ?? 'Unlock unlimited conversions and premium features',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: onUpgrade,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.accentOrange,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Upgrade',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
