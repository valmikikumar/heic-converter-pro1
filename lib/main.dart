import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:go_router/go_router.dart';
import 'package:heic_converter_pro/firebase_options.dart';
import 'package:heic_converter_pro/screens/splash_screen.dart';
import 'package:heic_converter_pro/screens/onboarding_screen.dart';
import 'package:heic_converter_pro/screens/auth/login_screen.dart';
import 'package:heic_converter_pro/screens/auth/signup_screen.dart';
import 'package:heic_converter_pro/screens/auth/otp_screen.dart';
import 'package:heic_converter_pro/screens/home_screen.dart';
import 'package:heic_converter_pro/screens/conversion_result_screen.dart';
import 'package:heic_converter_pro/screens/profile_screen.dart';
import 'package:heic_converter_pro/screens/settings_screen.dart';
import 'package:heic_converter_pro/providers/auth_provider.dart';
import 'package:heic_converter_pro/utils/app_theme.dart';
import 'package:heic_converter_pro/utils/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Initialize Google Mobile Ads
  await MobileAds.instance.initialize();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const ProviderScope(child: HEICConverterProApp()));
}

class HEICConverterProApp extends ConsumerWidget {
  const HEICConverterProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: AppRoutes.otp,
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>?;
        return OTPScreen(
          verificationId: args?['verificationId'] as String? ?? '',
          phoneNumber: args?['phoneNumber'] as String? ?? '',
        );
      },
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.conversionResult,
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        return ConversionResultScreen(
          convertedFiles: args['convertedFiles'] as List<String>,
          outputFormat: args['outputFormat'] as String,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);