# Services

- `api_service.dart`: HTTP client for backend (auth, health submit, history, list by type). Uses platform-aware base URL. Include `additionalData.diastolic` when submitting BP.
- `auth_service.dart`: Token storage and auth helpers.
- `health_import_service.dart`: Deprecated placeholder (automatic import removed). Safe to delete.

Tip: Ensure backend base URL matches your environment.
