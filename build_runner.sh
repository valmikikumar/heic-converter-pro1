#!/bin/bash

# HEIC Converter - Build Runner Script
# This script helps with code generation and building the Flutter app

echo "🚀 HEIC Converter - Build Runner"
echo "================================"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Generate code
echo "🔧 Generating code..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Analyze code
echo "🔍 Analyzing code..."
flutter analyze

# Run tests (if any)
echo "🧪 Running tests..."
flutter test

echo "✅ Build process completed!"
echo ""
echo "To run the app:"
echo "  flutter run"
echo ""
echo "To build APK:"
echo "  flutter build apk --release"
echo ""
echo "To build iOS:"
echo "  flutter build ios --release"
