import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';
import '../utils/app_theme.dart';
import '../widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLastPage = false;

  final List<OnboardingData> _onboardingPages = [
    OnboardingData(
      title: 'Welcome to HEIC Converter Pro',
      description: 'Convert your HEIC photos to multiple formats with professional quality and speed.',
      icon: Icons.photo_library_outlined,
      gradient: AppTheme.primaryGradient,
    ),
    OnboardingData(
      title: 'Free Features',
      description: '• Convert HEIC to JPG, PNG, PDF\n• Batch conversion (up to 50 files)\n• Basic image editing tools\n• Cloud sync across devices',
      icon: Icons.free_breakfast,
      gradient: const LinearGradient(
        colors: [Colors.green, Colors.lightGreen],
      ),
    ),
    OnboardingData(
      title: 'Pro Features',
      description: '• Unlimited batch conversions\n• Advanced editing tools\n• No advertisements\n• Priority support\n• Premium templates',
      icon: Icons.workspace_premium,
      gradient: AppTheme.accentGradient,
    ),
    OnboardingData(
      title: 'Ready to Start?',
      description: 'Sign in to sync your conversions across all devices and unlock the full potential of HEIC Converter Pro.',
      icon: Icons.rocket_launch,
      gradient: AppTheme.primaryGradient,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isCompleted = prefs.getBool(AppConstants.keyOnboardingCompleted) ?? false;
    
    if (isCompleted && mounted) {
      context.go(AppRoutes.login);
    }
  }

  void _nextPage() {
    if (_currentPage < _onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.shortAnimationDuration,
        curve: AppTheme.defaultCurve,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: AppConstants.shortAnimationDuration,
        curve: AppTheme.defaultCurve,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyOnboardingCompleted, true);
    
    if (mounted) {
      context.go(AppRoutes.login);
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page indicator
                  Row(
                    children: List.generate(
                      _onboardingPages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  
                  // Skip button
                  if (!_isLastPage)
                    TextButton(
                      onPressed: _skipOnboarding,
                      child: const Text('Skip'),
                    ),
                ],
              ),
            ),
            
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                    _isLastPage = index == _onboardingPages.length - 1;
                  });
                },
                itemCount: _onboardingPages.length,
                itemBuilder: (context, index) {
                  return OnboardingPage(
                    data: _onboardingPages[index],
                    isLastPage: index == _onboardingPages.length - 1,
                  );
                },
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  if (_currentPage > 0)
                    OutlinedButton.icon(
                      onPressed: _previousPage,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                    )
                  else
                    const SizedBox(width: 100),
                  
                  // Next/Get Started button
                  ElevatedButton.icon(
                    onPressed: _nextPage,
                    icon: Icon(_isLastPage ? Icons.login : Icons.arrow_forward),
                    label: Text(_isLastPage ? 'Get Started' : 'Next'),
                    style: AppTheme.gradientButtonStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Gradient gradient;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
  });
}
