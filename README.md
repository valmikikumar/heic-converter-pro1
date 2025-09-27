# 📱 HEIC Converter Pro

Professional HEIC to JPG/PNG/PDF conversion app with batch processing, Firebase authentication, and premium features.

## 🚀 Features

### ✅ Core Features
- **HEIC Conversion** - Convert HEIC/HEIF to JPG, PNG, PDF
- **Batch Processing** - Convert multiple files at once
- **High Quality** - Maintain original image quality
- **EXIF Preservation** - Keep metadata intact

### ✅ Free vs Pro
- **Free Users**: 50 conversions limit, ads
- **Pro Users**: Unlimited conversions, no ads, premium tools

### ✅ Authentication
- **Email/Password** login
- **Google Sign-In** integration
- **Phone OTP** verification
- **Cloud Sync** across devices

### ✅ UI/UX
- **Material 3** design system
- **Dark/Light** mode support
- **Smooth animations** and transitions
- **Responsive** layout for all devices

## 🛠️ Tech Stack

- **Flutter** 3.16.0
- **Firebase** (Auth, Firestore, Storage)
- **AdMob** integration
- **Google Play Billing**
- **Riverpod** state management
- **Material 3** UI components

## 📱 Screenshots

- Splash Screen with gradient branding
- Home screen with file upload
- Conversion progress with real-time updates
- Results screen with preview and sharing
- Profile screen with Pro upgrade options
- Settings screen with theme preferences

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.16.0+
- Android Studio
- Firebase project setup

### Installation
1. Clone the repository
2. Run `flutter pub get`
3. Configure Firebase
4. Run `flutter run`

### Build APK
```bash
flutter build apk --release
```

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── screens/                  # All app screens
│   ├── auth/                # Authentication screens
│   ├── home_screen.dart     # Main home screen
│   ├── conversion_*.dart    # Conversion screens
│   └── ...
├── services/                 # Business logic
├── models/                   # Data models
├── widgets/                  # Reusable UI components
└── utils/                    # Utilities and constants
```

## 🔧 Configuration

### Firebase Setup
1. Create Firebase project
2. Add `google-services.json` to `android/app/`
3. Update `lib/firebase_options.dart`

### AdMob Setup
1. Create AdMob account
2. Update Ad Unit IDs in `lib/utils/app_constants.dart`

### Google Play Billing
1. Setup Google Play Console
2. Configure product IDs
3. Test in-app purchases

## 📱 Build & Deploy

This project automatically builds APK using GitHub Actions:

1. Push code to main branch
2. GitHub Actions builds APK automatically
3. Download APK from Actions artifacts
4. Or download from Releases section

## 🎯 Features in Detail

### Conversion Engine
- Support for HEIC/HEIF formats
- Output to JPG, PNG, PDF
- Batch processing with progress tracking
- Quality and size optimization

### User Management
- Firebase Authentication
- User profiles and settings
- Pro subscription management
- Cross-device synchronization

### Monetization
- AdMob banner and interstitial ads
- Google Play Billing integration
- Free vs Pro feature differentiation
- Subscription management

## 🚀 Production Ready

This app is production-ready with:
- ✅ Complete feature implementation
- ✅ Professional UI/UX design
- ✅ Firebase integration
- ✅ Monetization setup
- ✅ Error handling
- ✅ Performance optimization

## 📄 License

This project is licensed under the MIT License.

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## 📞 Support

For support, email support@heicconverterpro.com

---

**Ready to convert HEIC files like a pro! 🚀**