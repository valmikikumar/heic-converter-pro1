# 🚀 Building HEIC Converter Pro APK

## Prerequisites

### 1. Install Flutter
```bash
# Download Flutter SDK
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.16.0-stable.zip

# Extract to a location like ~/development
unzip flutter_macos_3.16.0-stable.zip
mv flutter ~/development/

# Add to PATH (add to ~/.zshrc or ~/.bash_profile)
echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
source ~/.zshrc

# Verify installation
flutter doctor
```

### 2. Install Android Studio
1. Download from https://developer.android.com/studio
2. Install Android SDK
3. Accept all licenses: `flutter doctor --android-licenses`

### 3. Set Up Project
```bash
# Navigate to project directory
cd "HEIC Converter/heic_converter_pro"

# Get dependencies
flutter pub get

# Generate code (if needed)
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## Build Commands

### Debug APK (for testing)
```bash
flutter build apk --debug
```

### Release APK (for production)
```bash
flutter build apk --release
```

### App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

## Build Output Locations

- **Debug APK**: `build/app/outputs/flutter-apk/app-debug.apk`
- **Release APK**: `build/app/outputs/flutter-apk/app-release.apk`
- **App Bundle**: `build/app/outputs/bundle/release/app-release.aab`

## Troubleshooting

### Common Issues:

1. **Flutter not found**: Make sure Flutter is in your PATH
2. **Android SDK not found**: Install Android Studio and SDK
3. **Licenses not accepted**: Run `flutter doctor --android-licenses`
4. **Build fails**: Check dependencies with `flutter pub get`

### Build Optimization:
```bash
# Clean build cache
flutter clean

# Rebuild from scratch
flutter pub get
flutter build apk --release
```

## Quick Build Script

Create a file called `build.sh`:

```bash
#!/bin/bash
echo "🚀 Building HEIC Converter Pro APK..."

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Generate code
flutter packages pub run build_runner build --delete-conflicting-outputs

# Build release APK
flutter build apk --release

echo "✅ Build complete!"
echo "📱 APK location: build/app/outputs/flutter-apk/app-release.apk"
```

Make it executable and run:
```bash
chmod +x build.sh
./build.sh
```

## Next Steps After Building

1. **Test the APK** on Android devices
2. **Sign the APK** for distribution
3. **Upload to Play Store** or distribute directly
4. **Set up Firebase** with your project credentials
5. **Configure AdMob** with your Ad Unit IDs
6. **Set up Google Play Billing** for subscriptions

---

**Note**: Make sure to update the Firebase configuration and AdMob settings before building for production!
