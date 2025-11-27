# MedNet - Your Health Companion 🩺

A beautiful, minimalist mobile health tracking application built with Flutter. Track your vital health metrics including Heart Rate, Blood Pressure, Blood Sugar, and Temperature with an intuitive, soothing interface.

## Features

### ✅ Implemented Features

- **Splash Screen**: Beautiful animated splash screen with logo
- **Authentication**: Secure sign up and login functionality
- **Home Page**: Real-time display of health metrics (Heart Rate, Blood Pressure, Temperature)
- **Profile Page**: User profile management with editable information
- **Analysis Page**: Health history and trends visualization
- **Bottom Navigation**: Seamless navigation between Home, Analysis, and Profile
- **Professional UI**: Minimalist design with a soothing color palette

### 🎨 Design

The app uses a professional, minimalist color palette designed to be soothing and relaxing:

- **Primary Colors**:
  - Calm Blue (#4A90E2) - Classic health color
  - Navy (#16324F) - Strong, stable

- **Secondary Colors**:
  - Ice Blue (#EAF6FF) - Gentle, tranquil
  - Fog Gray (#D8DDE6) - Light UI dividers
  - Cool Graphite (#5C677D) - Text, icons

- **Accent Colors**:
  - Sea Green (#53D1B6) - Positive health indicators

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── user_model.dart      # User data model
│   └── health_data_model.dart # Health metrics model
├── pages/
│   ├── splash_screen.dart   # Animated splash screen
│   ├── auth_page.dart       # Sign up/Login page
│   ├── home_page.dart       # Main dashboard with health metrics
│   ├── profile_page.dart    # User profile management
│   ├── analysis_page.dart   # Health history and analysis
│   └── main_screen.dart     # Bottom navigation wrapper
├── services/
│   ├── api_service.dart     # Backend API integration
│   └── auth_service.dart    # Authentication service
└── theme/
    └── app_theme.dart       # App theme and colors
```

## Getting Started

### Prerequisites

- Flutter SDK (3.10.1 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Backend API endpoint (see API_ENDPOINTS.md)

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd med_net
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Update API endpoint:
   - Open `lib/services/api_service.dart`
   - Update the `baseUrl` constant with your backend API URL

4. Add your logo:
   - Place your app logo in `assets/images/`
   - Update `lib/pages/splash_screen.dart` to use your logo

5. Run the app:
   ```bash
   flutter run
   ```

## API Integration

The app is ready to connect to your backend API. All endpoints are documented in `API_ENDPOINTS.md`.

### Required Endpoints

1. **Authentication**:
   - `POST /auth/signup` - User registration
   - `POST /auth/login` - User login

2. **User Management**:
   - `GET /users/me` - Get user profile
   - `PUT /users/me` - Update user profile

3. **Health Data**:
   - `GET /health/current` - Get current health metrics
   - `GET /health/{type}` - Get health data by type
   - `GET /health/history` - Get health history for analysis
   - `POST /health/submit` - Submit new health data

See `API_ENDPOINTS.md` for detailed API documentation.

## Configuration

### Update Backend URL

Edit `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'https://your-backend-api.com/api';
```

### Add Custom Logo

1. Place your logo in `assets/images/logo.png`
2. Update `pubspec.yaml` to include the image
3. Update `lib/pages/splash_screen.dart` to load your logo

## Dependencies

- `flutter`: SDK
- `http`: ^1.1.0 - HTTP requests
- `shared_preferences`: ^2.2.2 - Local storage
- `cupertino_icons`: ^1.0.8 - iOS-style icons

## Development

### Running on Different Platforms

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web (if configured)
flutter run -d chrome
```

### Building for Release

```bash
# Android APK
flutter build apk

# iOS
flutter build ios
```

## Future Enhancements

- [ ] Graph visualization for health trends
- [ ] Integration with wearable devices
- [ ] Push notifications for health reminders
- [ ] Export health reports
- [ ] Multiple user profiles
- [ ] Health goal setting and tracking

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

[Add your license here]

## Support

For issues and questions, please open an issue on the repository.

---

**Made with ❤️ for better health tracking**
