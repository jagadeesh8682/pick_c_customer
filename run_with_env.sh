#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
    echo "✅ Environment variables loaded from .env file"
else
    echo "❌ .env file not found. Please create it with your API keys."
    exit 1
fi

# Check if required API keys are set
if [ -z "$GOOGLE_MAPS_API_KEY" ]; then
    echo "❌ GOOGLE_MAPS_API_KEY is not set in .env file"
    exit 1
fi

echo "🚀 Starting Flutter app with Google Maps API key..."
echo "📍 Maps API Key: ${GOOGLE_MAPS_API_KEY:0:10}..."

# Run Flutter
flutter run
