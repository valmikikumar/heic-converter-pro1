import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../utils/app_theme.dart';
import 'onboarding_screen.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  final bool isLastPage;

  const OnboardingPage({
    super.key,
    required this.data,
    required this.isLastPage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimationLimiter(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            // Icon with gradient background
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: data.gradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                data.icon,
                size: 60,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                data.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                data.description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
            ),
            
            if (isLastPage) ...[
              const SizedBox(height: 40),
              
              // Pro badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.workspace_premium,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pro Features Available',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
