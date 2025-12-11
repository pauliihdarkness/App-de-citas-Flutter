#!/bin/bash

# Script to install Flutter in Netlify build environment
# This script is optimized for Netlify free tier to minimize build time

set -e  # Exit on error

echo "🚀 Installing Flutter for Netlify build..."

# Use /opt/buildhome for Flutter installation (Netlify's home directory)
FLUTTER_HOME="/opt/buildhome/flutter"

# Check if Flutter is already installed (from cache)
if [ -d "$FLUTTER_HOME" ]; then
  echo "✅ Flutter found in cache, skipping download"
  export PATH="$PATH:$FLUTTER_HOME/bin"
  flutter --version
  exit 0
fi

# Install Flutter
echo "📦 Downloading Flutter SDK..."
cd /opt/buildhome
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# Add Flutter to PATH
export PATH="$PATH:$FLUTTER_HOME/bin"

# Disable analytics to speed up build
flutter config --no-analytics

# Enable web support
flutter config --enable-web

# Pre-download dependencies (speeds up subsequent builds)
echo "📥 Pre-downloading Flutter dependencies..."
flutter precache --web

# Verify installation
echo "✅ Flutter installed successfully:"
flutter --version
flutter doctor -v

echo "🎉 Flutter installation complete!"
echo "Flutter is available at: $FLUTTER_HOME"
