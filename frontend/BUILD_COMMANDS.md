# Build Commands for Mobile Deployment

## Prerequisites

1. **Install Flutter Dependencies** (First time only):
   ```bash
   flutter pub get
   ```

2. **Check Flutter Setup**:
   ```bash
   flutter doctor
   ```

## For Android Devices 📱

### Step 1: Enable Developer Options on Your Phone
- Go to Settings → About Phone
- Tap "Build Number" 7 times
- Go back to Settings → Developer Options
- Enable "USB Debugging"

### Step 2: Connect Your Device
- Connect your Android phone via USB
- Accept the USB debugging prompt on your phone

### Step 3: Check Connected Devices
```bash
flutter devices
```

### Step 4: Build and Run on Android

**Option A: Run directly on connected device (Recommended for testing)**
```bash
flutter run
```

**Option B: Build and Install APK**
```bash
# Debug APK (for testing)
flutter build apk --debug

# Release APK (for distribution)
flutter build apk --release
```

The APK will be located at:
- Debug: `build/app/outputs/flutter-apk/app-debug.apk`
- Release: `build/app/outputs/flutter-apk/app-release.apk`

**Option C: Build App Bundle (for Play Store)**
```bash
flutter build appbundle --release
```

The bundle will be at: `build/app/outputs/bundle/release/app-release.aab`

### Install APK Manually
```bash
# Install debug APK
adb install build/app/outputs/flutter-apk/app-debug.apk

# Install release APK
adb install build/app/outputs/flutter-apk/app-release.apk
```

## For iOS Devices 🍎

### Prerequisites
- macOS computer (required for iOS development)
- Xcode installed
- iOS Developer account (for physical device)

### Step 1: Open iOS Simulator or Connect iPhone
```bash
# List available iOS simulators
flutter devices

# Open specific simulator
open -a Simulator
```

### Step 2: Build and Run

**For iOS Simulator:**
```bash
flutter run
```

**For Physical iPhone:**
1. Connect iPhone via USB
2. Trust the computer on your iPhone
3. Open Xcode → Window → Devices and Simulators
4. Select your device and enable development mode
5. Run:
```bash
flutter run -d <device-id>
```

**Build iOS App:**
```bash
# Build for iOS (creates .ipa file)
flutter build ios --release
```

## Quick Commands Cheat Sheet

### Check Setup
```bash
flutter doctor                    # Check Flutter setup
flutter devices                   # List connected devices
flutter doctor -v                 # Detailed setup info
```

### Install Dependencies
```bash
flutter pub get                   # Install packages
flutter pub upgrade               # Update packages
flutter clean                     # Clean build cache
flutter pub add health            # Add Health Connect/HealthKit integration
```

### Run App
```bash
flutter run                       # Run on connected device
flutter run -d <device-id>        # Run on specific device
flutter run --release             # Run in release mode
```

### Build APK (Android)
```bash
flutter build apk                 # Debug APK
flutter build apk --release       # Release APK (optimized)
flutter build apk --split-per-abi # Split APKs by architecture
```

### Build Bundle (Android Play Store)
```bash
flutter build appbundle --release
```

### Build iOS
```bash
flutter build ios                 # Build iOS app
flutter build ios --release       # Release build
```

### Hot Reload (While App is Running)
- Press `r` in terminal for hot reload
- Press `R` for hot restart
- Press `q` to quit

## Troubleshooting

### Android Issues

**Device not detected:**
```bash
adb devices                       # Check if device is connected
adb kill-server                  # Restart ADB server
adb start-server                 # Start ADB server
```

**Build errors:**
```bash
flutter clean                     # Clean build cache
flutter pub get                   # Reinstall dependencies
flutter doctor                    # Check for issues
```

**Permission denied:**
- Make sure USB debugging is enabled
- Try a different USB cable/port
- Check Windows Device Manager for driver issues

### iOS Issues

**Code signing errors:**
- Open iOS project in Xcode: `open ios/Runner.xcworkspace`
- Select your team in Signing & Capabilities
- Ensure valid provisioning profile

**Build fails:**
```bash
cd ios
pod install                      # Install iOS dependencies
cd ..
flutter clean
flutter pub get
```

## Health Connect / HealthKit Setup

### Android (Health Connect)
- Ensure the Health Connect app is installed on the device.
- Grant permissions when prompted in-app for Heart Rate, Blood Pressure, and Body Temperature.
- No AndroidManifest permissions are required; permissions are requested at runtime.

### iOS (HealthKit)
- On macOS, open `ios/Runner.xcworkspace` in Xcode and enable HealthKit capability.
- Add Health usage description to Info.plist if prompted by the `health` package.
- The app will request read permissions at runtime for the selected data types.

### Import Flow
- In the Analysis page, use the "Import from Health" button to request permissions and fetch records for the selected type.
- Imported records are submitted to the backend (`/health/submit`) and appear in history.

## Build Sizes

**Debug APK**: ~50-80 MB (includes debug symbols)
**Release APK**: ~15-30 MB (optimized, smaller size)

## Distribution

### Android (Play Store)
1. Build app bundle: `flutter build appbundle --release`
2. Upload `app-release.aab` to Google Play Console

### Android (Direct Install)
1. Build APK: `flutter build apk --release`
2. Transfer `app-release.apk` to phone
3. Enable "Install from Unknown Sources" on phone
4. Install APK

### iOS (App Store)
1. Build in Xcode: `flutter build ios --release`
2. Open `ios/Runner.xcworkspace` in Xcode
3. Archive and upload via Xcode


