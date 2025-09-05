#!/bin/bash
# Exit immediately if a command exits with a non-zero status.

set -e
echo "🚀 Starting Flutter Builds & deployments..."

echo "📦 Running Flutter clean..."
fvm flutter clean

echo "📦 Getting Flutter dependencies..."
fvm flutter pub get

# ================================
# 📋 Get Flutter app version name & code
# ================================
# Check if pubspec.yaml exists
if [[ ! -f "pubspec.yaml" ]]; then
	echo "❌ Error: pubspec.yaml not found in current directory"
	exit 1
fi
# Extract version from pubspec.yaml
EXISTING_VERSION=$(grep '^version:' pubspec.yaml | cut -d' ' -f2 | tr -d '\r\n')
# Split version name and code
VERSION_NAME=$(echo "$EXISTING_VERSION" | cut -d'+' -f1)
VERSION_CODE=$(echo "$EXISTING_VERSION" | cut -d'+' -f2 | tr -d '\r\n' | sed 's/[^0-9]//g')

echo "📝 Version Name: $VERSION_NAME"
echo "🔢 Version Code: $VERSION_CODE"

# ================================
# 📋 Checking & fixing fastlane
# ================================
echo "📦 Installing Fastlane dependencies..."
cd android
if [[ -f "Gemfile" ]]; then
	echo "📦 Installing Ruby gems..."
	rm -f Gemfile.lock
	bundle install
else
	echo "⚠️ Gemfile not found, skipping gem installation."
fi

cd ../ios
if [[ -f "Gemfile" ]]; then
	echo "📦 Installing Ruby gems..."
	rm -f Gemfile.lock
	bundle install
else
	echo "⚠️ Gemfile not found, skipping gem installation."
fi
cd ..

## ===========================================
## Android Build & Deployment
## ===========================================
# echo "📦 Building Android AAB..."
# fvm flutter build appbundle
# AAB_PATH=$(find build/app/outputs/bundle/release -name "*.aab" | head -n 1)
# NEW_AAB_PATH="build/app/outputs/bundle/release/app.aab"
# mv "$AAB_PATH" "$NEW_AAB_PATH"
# AAB_PATH="$NEW_AAB_PATH"
# AAB_PATH=$(realpath "$AAB_PATH")
# if [[ -z "$AAB_PATH" ]]; then
# 	echo "❌ AAB file not found."
# 	exit 1
# fi
# echo "✅ New AAB: $AAB_PATH"
# echo "🚀 Deploying AAB with Fastlane..."
# cd android
# bundle exec fastlane deploy aab_path:"$AAB_PATH"
# cd ..

## ===========================================
## Android APK & copy to Downloads
## ===========================================
echo "📦 Building Android APK..."
fvm flutter build apk
APK_PATH=$(find build/app/outputs/flutter-apk -name "*-release.apk" | head -n 1)
PROJECT_NAME=$(grep '^name:' pubspec.yaml | awk '{print $2}' | tr -d '\r\n')

# Clean up the project name for filename
# Replace underscores with hyphens and remove any problematic characters
CLEAN_PROJECT_NAME=$(echo "$PROJECT_NAME" | sed 's/_/-/g' | sed 's/[^a-zA-Z0-9-]//g')
NEW_APK_NAME="${CLEAN_PROJECT_NAME}-v${VERSION_NAME}+${VERSION_CODE}.apk"
DOWNLOAD_DIR="$HOME/Downloads"

# Debug output
echo "🔍 Debug - PROJECT_NAME: '$PROJECT_NAME'"
echo "🔍 Debug - CLEAN_PROJECT_NAME: '$CLEAN_PROJECT_NAME'"
echo "🔍 Debug - NEW_APK_NAME: '$NEW_APK_NAME'"

if [[ -z "$APK_PATH" ]]; then
	echo "❌ APK file not found."
	exit 1
elif [[ ! -f "$APK_PATH" ]]; then
	echo "❌ APK file does not exist at: $APK_PATH"
	exit 1
else
	cp "$APK_PATH" "$DOWNLOAD_DIR/$NEW_APK_NAME"
	echo "✅ APK copied to $DOWNLOAD_DIR/$NEW_APK_NAME"
	# Optional: Show file size
	APK_SIZE=$(ls -lh "$DOWNLOAD_DIR/$NEW_APK_NAME" | awk '{print $5}')
	echo "📊 APK size: $APK_SIZE"
fi

# ===========================================
# Firebase App Distribution Upload
# ===========================================

# Configuration
FIREBASE_APP_ID="1:541096490711:android:255f37843926fd9b826292"  # Replace with your actual app ID
TESTERS="lakshay@appcrew.in"  # Comma-separated list of testers
RELEASE_NOTES="Uploaded via CI script"

if ! command -v firebase &> /dev/null; then
  echo "❌ Firebase CLI not installed. Install it with: npm install -g firebase-tools"
  exit 1
fi

echo "☁️ Uploading to Firebase App Distribution..."
firebase appdistribution:distribute "$APK_PATH" \
  --app "$FIREBASE_APP_ID" \
  --testers "$TESTERS" \
  --release-notes "$RELEASE_NOTES"

if [[ $? -eq 0 ]]; then
  echo "✅ Successfully uploaded to Firebase App Distribution"
else
  echo "❌ Failed to upload to Firebase App Distribution"
  exit 1
fi

## ===========================================
## iOS Build & Deployment
## ===========================================
fvm flutter precache --ios
echo "📦 Installing iOS pods..."
cd ios
pod install
cd ..
echo "📦 Building iOS IPA..."
fvm flutter build ipa
IPA_PATH=$(find build/ios/ipa -name "*.ipa" | head -n 1)
NEW_IPA_PATH="build/ios/ipa/app.ipa"
mv "$IPA_PATH" "$NEW_IPA_PATH"
IPA_PATH="$NEW_IPA_PATH"
IPA_PATH=$(realpath "$IPA_PATH")
if [[ -z "$IPA_PATH" ]]; then
	echo "❌ IPA file not found."
	exit 1
fi
echo "✅ New IPA: $IPA_PATH"
echo "🚀 Deploying iOS with Fastlane..."
cd ios
bundle exec fastlane deploy ipa_path:"$IPA_PATH"

## ===========================================
## Web Build & Deployment
## ===========================================
# echo "📦 Building & Deploying web..."
# fvm flutter build web
# firebase deploy --only hosting
# firebase deploy --only functions
echo "✅ Deployment complete!"