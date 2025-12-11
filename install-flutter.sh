#!/bin/bash

# Script to install Flutter in Netlify build environment
# This script is optimized for Netlify free tier to minimize build time

set -e  # Exit on error

echo "🚀 Installing Flutter for Netlify build..."

# Check if Flutter is already installed (from cache)
if [ -d "$HOME/flutter" ]; then
  echo "✅ Flutter found in cache, skipping download"
  export PATH="$PATH:$HOME/flutter/bin"
  flutter --version
  exit 0
fi

# Install Flutter
echo "📦 Downloading Flutter SDK..."
cd $HOME
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# Add Flutter to PATH
export PATH="$PATH:$HOME/flutter/bin"

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
