# Flutter App Structure (lib)

- `main.dart`: App entry; routing and theme setup.
- `models/`: Data models for user and health data.
- `services/`: API/auth services and utilities.
- `pages/`: Screens (Auth, Home, Analysis, Profile, etc.).
- `theme/`: App theming and color definitions.

## Key Flows
- Home: manual entry updates local UI; the Save FAB submits all three metrics in one call sequence (HR, BP with `additionalData.diastolic`, Temp).
- Analysis: shows current summary and full history with severity coloring; BP tiles render `SYS/DIA mmHg`.

## API Base URL
- Configured in `services/api_service.dart` with platform-aware logic. Update backend host/port there if needed.
