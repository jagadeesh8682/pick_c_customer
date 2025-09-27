#!/bin/bash

# Build script for Pick C Customer App
# This script loads environment variables from .env and builds the app

echo "🚛 Pick C Customer App - Build Script"
echo "====================================="

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "❌ Error: .env file not found!"
    echo "Please create a .env file with your API keys:"
    echo "GOOGLE_MAPS_API_KEY=your_api_key_here"
    echo "GOOGLE_PLACES_API_KEY=your_api_key_here"
    echo "GOOGLE_DIRECTIONS_API_KEY=your_api_key_here"
    exit 1
fi

echo "📄 Loading environment variables from .env file..."

# Load environment variables from .env file
export $(grep -v '^#' .env | xargs)

# Verify API keys are loaded
if [ -z "$GOOGLE_MAPS_API_KEY" ]; then
    echo "❌ Error: GOOGLE_MAPS_API_KEY not found in .env file"
    exit 1
fi

if [ -z "$GOOGLE_PLACES_API_KEY" ]; then
    echo "❌ Error: GOOGLE_PLACES_API_KEY not found in .env file"
    exit 1
fi

if [ -z "$GOOGLE_DIRECTIONS_API_KEY" ]; then
    echo "❌ Error: GOOGLE_DIRECTIONS_API_KEY not found in .env file"
    exit 1
fi

echo "✅ Environment variables loaded successfully"
echo "🔑 Maps API Key: ${GOOGLE_MAPS_API_KEY:0:20}..."
echo "🔑 Places API Key: ${GOOGLE_PLACES_API_KEY:0:20}..."
echo "🔑 Directions API Key: ${GOOGLE_DIRECTIONS_API_KEY:0:20}..."

# Get build type from command line argument
BUILD_TYPE=${1:-debug}

echo ""
echo "🔨 Building Flutter app ($BUILD_TYPE mode)..."

# Build the Flutter app
if [ "$BUILD_TYPE" = "release" ]; then
    echo "📱 Building release APK..."
    flutter build apk --release
else
    echo "📱 Building debug APK..."
    flutter build apk --debug
fi

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 Build completed successfully!"
    echo ""
    echo "📋 Next steps:"
    echo "1. Install the APK on your device"
    echo "2. Test the map functionality"
    echo "3. Verify API keys are working"
    echo ""
    echo "📁 APK location:"
    if [ "$BUILD_TYPE" = "release" ]; then
        echo "   build/app/outputs/flutter-apk/app-release.apk"
    else
        echo "   build/app/outputs/flutter-apk/app-debug.apk"
    fi
else
    echo ""
    echo "❌ Build failed!"
    echo "Please check the error messages above and fix any issues."
    exit 1
fi

