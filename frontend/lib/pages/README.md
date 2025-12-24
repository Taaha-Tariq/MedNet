# Pages

- `auth_page.dart`: Login/Signup UI and flow.
- `home_page.dart`: Manual entry for HR, BP (SYS/DIA), Temp; Save FAB sends all three metrics to backend.
- `analysis_page.dart`: Current summary + full history per type; severity colors; BP shows `SYS/DIA` from `additionalData.diastolic`.
- `profile_page.dart`: Profile details and updates.
- `main_screen.dart`: Shell with bottom nav.
- `splash_screen.dart`: Initial boot splash.

Notes:
- First load shows bars (—) for null values until user enters data.
