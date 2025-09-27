#!/bin/bash

# HEIC Converter Pro - Build Script
echo "🚀 HEIC Converter Pro - Building APK..."
echo "======================================"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    echo "Please install Flutter first: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check Flutter doctor
echo "📋 Checking Flutter setup..."
flutter doctor

echo ""
echo "🧹 Cleaning previous builds..."
flutter clean

echo ""
echo "📦 Getting dependencies..."
flutter pub get

echo ""
echo "🔧 Generating code..."
flutter packages pub run build_runner build --delete-conflicting-outputs

echo ""
echo "🔍 Analyzing code..."
flutter analyze

echo ""
echo "🏗️ Building release APK..."
flutter build apk --release

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build completed successfully!"
    echo "📱 APK location: build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "📊 APK Info:"
    ls -lh build/app/outputs/flutter-apk/app-release.apk
    echo ""
    echo "🎉 Ready for distribution!"
else
    echo ""
    echo "❌ Build failed!"
    echo "Please check the error messages above and try again."
    exit 1
fi
