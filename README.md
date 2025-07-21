# MamaBhanja Driver App

Flutter-based mobile application for MamaBhanja delivery partners.

## 🚀 Development Environment

- **Flutter Version**: 3.32.5 (managed via FVM)
- **Dart Version**: 3.8.1
- **Last Build**: July 21, 2025

### 🛠 FVM (Flutter Version Management)

This project uses FVM (Flutter Version Management) to ensure consistent Flutter versions across the development team.

#### Setup FVM

1. Install FVM:

   ```bash
   dart pub global activate fvm
   ```

2. Install the correct Flutter version:

   ```bash
   fvm install 3.32.5
   ```

3. Configure the project to use the specific Flutter version:

   ```bash
   fvm use 3.32.5
   ```

4. Run Flutter commands through FVM:
   ```bash
   fvm flutter pub get
   fvm flutter run
   ```

## 📱 Getting Started

### Prerequisites

- Flutter SDK (managed via FVM)
- Android Studio / VS Code with Flutter extensions
- Xcode (for iOS development)
- CocoaPods (for iOS dependencies)

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   fvm flutter pub get
   ```
3. Run the app:
   ```bash
   fvm flutter run
   ```

## 📦 Dependencies

- Firebase Authentication
- Cloud Firestore
- Google Sign-In
- And more (see `pubspec.yaml` for complete list)

## 📝 Version Information

- **Current Version**: 1.1.0+110
- **Last Updated**: July 21, 2025
