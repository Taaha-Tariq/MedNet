# MedNet Setup Guide

## Quick Start

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Update Backend URL**:
   - Open `lib/services/api_service.dart`
   - Change line 8: `static const String baseUrl = 'https://your-backend-api.com/api';`
   - Replace with your actual backend API URL

3. **Add Your Logo** (Optional):
   - Place your logo image in `assets/images/logo.png`
   - Update `lib/pages/splash_screen.dart` to use your logo instead of the placeholder icon

4. **Run the App**:
   ```bash
   flutter run
   ```

## Project Overview

### ✅ Completed Features

1. **Splash Screen** (`lib/pages/splash_screen.dart`)
   - Animated logo with fade and scale effects
   - Auto-navigation to Auth or Main screen based on login status

2. **Authentication Page** (`lib/pages/auth_page.dart`)
   - Tab-based interface (Login/Sign Up)
   - Form validation
   - Beautiful minimalist design

3. **Home Page** (`lib/pages/home_page.dart`)
   - Display health metrics (Heart Rate, Blood Pressure, Temperature)
   - Quick action buttons for checking each metric
   - Refresh functionality

4. **Profile Page** (`lib/pages/profile_page.dart`)
   - View and edit user information
   - Logout functionality

5. **Analysis Page** (`lib/pages/analysis_page.dart`)
   - Filter by health metric type
   - Health history display
   - Placeholder for graph visualization

6. **Main Screen** (`lib/pages/main_screen.dart`)
   - Bottom navigation bar
   - Three tabs: Home, Analysis, Profile

### 🎨 Design Implementation

The app uses the exact color palette you specified:
- **Primary**: Calm Blue (#4A90E2), Navy (#16324F)
- **Secondary**: Ice Blue (#EAF6FF), Fog Gray (#D8DDE6), Cool Graphite (#5C677D)
- **Accent**: Sea Green (#53D1B6)

All pages follow a minimalist, professional design that's soothing and easy on the eyes.

### 📁 File Structure

```
lib/
├── main.dart                      # App entry point
├── models/
│   ├── user_model.dart           # User data structure
│   └── health_data_model.dart    # Health metrics structure
├── pages/
│   ├── splash_screen.dart        # Animated splash
│   ├── auth_page.dart            # Login/Sign up
│   ├── home_page.dart            # Health dashboard
│   ├── profile_page.dart         # User profile
│   ├── analysis_page.dart        # Health history
│   └── main_screen.dart          # Navigation wrapper
├── services/
│   ├── api_service.dart          # Backend API calls
│   └── auth_service.dart         # Authentication logic
└── theme/
    └── app_theme.dart            # App theme & colors
```

### 🔌 API Integration

The app is fully prepared for backend integration. All API endpoints are documented in `API_ENDPOINTS.md`.

**Key endpoints ready:**
- ✅ Authentication (signup/login)
- ✅ User profile management
- ✅ Health data fetching
- ✅ Health history/analysis
- ✅ Health data submission

### 📱 Navigation Flow

```
Splash Screen
    ↓
    ├─→ [Logged In] → Main Screen
    │                   ├─→ Home (default)
    │                   ├─→ Analysis
    │                   └─→ Profile
    │
    └─→ [Not Logged In] → Auth Page
                           ├─→ Login → Main Screen
                           └─→ Sign Up → Main Screen
```

### 🚀 Next Steps

1. **Backend Integration**:
   - Set up your backend API
   - Update the `baseUrl` in `api_service.dart`
   - Ensure your API matches the endpoints in `API_ENDPOINTS.md`

2. **Logo Replacement**:
   - Add your logo to `assets/images/`
   - Update splash screen to load your logo

3. **Graph Visualization** (Future):
   - Add a charting library (like `fl_chart` or `syncfusion_flutter_charts`)
   - Implement graph view in Analysis page

4. **Device Integration** (Future):
   - Add wearable device SDKs
   - Implement real-time health data fetching

### 🛠️ Development Notes

- The app uses `shared_preferences` for local token storage
- All API calls are async and handle errors gracefully
- The UI is responsive and follows Material Design 3
- Color scheme is centralized in `app_theme.dart` for easy customization

### 📝 Important Notes

- The app currently uses mock data on the Home page for demonstration
- Update the `getCurrentHealthData` method in `home_page.dart` to parse actual API responses
- Graph visualization is a placeholder - implement when ready
- All forms include validation

---

**Ready to launch!** 🎉


