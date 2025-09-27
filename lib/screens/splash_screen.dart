import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../providers/auth_provider.dart';
import '../utils/app_constants.dart';
import '../utils/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: AppConstants.mediumAnimationDuration,
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: AppConstants.mediumAnimationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: AppTheme.defaultCurve,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: AppTheme.elasticCurve,
    ));

    _startAnimations();
  }

  void _startAnimations() async {
    // Start fade in and scale animations
    await Future.wait([
      _fadeController.forward(),
      _scaleController.forward(),
    ]);

    // Wait for splash duration
    await Future.delayed(AppConstants.splashScreenDuration);

    // Check authentication status and navigate
    final authState = ref.read(authProvider);
    
    if (mounted) {
      if (authState.isAuthenticated) {
        context.go(AppRoutes.home);
      } else {
        context.go(AppRoutes.onboarding);
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo/Icon with Lottie animation
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.photo_library_outlined,
                          size: 70,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // App Name with gradient text
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [Colors.white, Colors.white.withOpacity(0.8)],
                        ).createShader(bounds),
                        child: Text(
                          AppConstants.appName,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Tagline
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Convert HEIC photos with professional quality',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            height: 1.4,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // Loading indicator with custom animation
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Version info
                      Text(
                        'Version ${AppConstants.appVersion}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}