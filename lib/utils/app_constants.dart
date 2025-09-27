class AppConstants {
  // App Info
  static const String appName = 'HEIC Converter Pro';
  static const String appVersion = '1.0.0';
  
  // Storage
  static const String userBox = 'user_data';
  static const String settingsBox = 'app_settings';
  static const String outputFolderName = 'HEIC-Converter-Pro';
  
  // File Extensions
  static const List<String> supportedInputFormats = ['heic', 'heif'];
  static const List<String> supportedOutputFormats = ['jpg', 'jpeg', 'png', 'pdf'];
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  
  // Conversion Settings
  static const double minResizePercentage = 50.0;
  static const double maxResizePercentage = 100.0;
  static const double defaultResizePercentage = 100.0;
  static const int minCompressionQuality = 80;
  static const int maxCompressionQuality = 100;
  static const int defaultCompressionQuality = 90;
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 300);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 1000);
  
  // Splash Screen
  static const Duration splashScreenDuration = Duration(seconds: 3);
  
  // Free vs Pro Limits
  static const int freeUserFileLimit = 50;
  static const int proUserFileLimit = -1; // Unlimited
  
  // Error Messages
  static const String errorFileNotFound = 'File not found';
  static const String errorConversionFailed = 'Conversion failed';
  static const String errorPermissionDenied = 'Permission denied';
  static const String errorStorageFull = 'Storage is full';
  static const String errorUnsupportedFormat = 'Unsupported file format';
  static const String errorFileLimitReached = 'File limit reached. Upgrade to Pro for unlimited conversions.';
  
  // Success Messages
  static const String successConversionComplete = 'All files converted successfully!';
  static const String successFileSaved = 'File saved successfully';
  static const String successFilesShared = 'Files shared successfully';
  static const String successProUpgrade = 'Welcome to Pro! Enjoy unlimited conversions.';
  
  // Settings Keys
  static const String keyDefaultOutputFormat = 'default_output_format';
  static const String keyKeepExifByDefault = 'keep_exif_by_default';
  static const String keyDefaultResizePercentage = 'default_resize_percentage';
  static const String keyCompressionQuality = 'compression_quality';
  static const String keyDarkMode = 'dark_mode';
  static const String keySaveLocation = 'save_location';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  
  // Default Values
  static const String defaultOutputFormat = 'jpg';
  static const bool defaultKeepExif = true;
  static const String defaultSaveLocation = 'Documents';
  
  // Navigation Routes
  static const String splashRoute = '/splash';
  static const String onboardingRoute = '/onboarding';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String otpRoute = '/otp';
  static const String homeRoute = '/home';
  static const String conversionResultRoute = '/conversion-result';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';
  
  // Icons
  static const String homeIcon = '🏠';
  static const String profileIcon = '👤';
  static const String settingsIcon = '⚙️';
  static const String successIcon = '✅';
  static const String errorIcon = '❌';
  static const String darkModeIcon = '🌙';
  static const String proIcon = '👑';
  
  // Format Display Names
  static const Map<String, String> formatDisplayNames = {
    'jpg': 'JPEG',
    'jpeg': 'JPEG',
    'png': 'PNG',
    'pdf': 'PDF',
  };
  
  // Format Descriptions
  static const Map<String, String> formatDescriptions = {
    'jpg': 'Best for photos, smaller file size',
    'png': 'Best for graphics, supports transparency',
    'pdf': 'Document format, multiple images per file',
  };
  
  // AdMob Ad Unit IDs (Replace with your actual IDs)
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // Test ID
  static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712'; // Test ID
  static const String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917'; // Test ID
  
  // Google Play Billing Product IDs
  static const String monthlySubscriptionId = 'monthly_pro_subscription';
  static const String yearlySubscriptionId = 'yearly_pro_subscription';
  static const String lifetimePurchaseId = 'lifetime_pro_purchase';
  
  // Firestore Collections
  static const String usersCollection = 'users';
  static const String conversionsCollection = 'conversions';
  static const String purchasesCollection = 'purchases';
}

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String otp = '/otp';
  static const String home = '/home';
  static const String conversionResult = '/conversion-result';
  static const String profile = '/profile';
  static const String settings = '/settings';
}