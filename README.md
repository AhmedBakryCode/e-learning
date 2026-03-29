# Elevate LMS

Production-ready Flutter starter for an e-learning platform with two dashboards:

- `Admin / Teacher`
- `Student`

## Stack

- `flutter_bloc` with Cubit-first state management
- `get_it` for dependency injection
- `dio` for API-ready networking
- `go_router` for role-based navigation
- Clean Architecture with `core/` and feature-first modules

## Folder Structure

```text
lib/
├── app/
│   ├── app.dart
│   ├── router/
│   │   ├── app_router.dart
│   │   └── go_router_refresh_stream.dart
│   └── theme/
│       ├── app_colors.dart
│       └── app_theme.dart
├── core/
│   ├── constants/
│   ├── di/
│   ├── error/
│   ├── extensions/
│   ├── network/
│   ├── usecases/
│   └── widgets/
├── features/
│   ├── auth/
│   ├── comments/
│   ├── courses/
│   ├── notifications/
│   ├── progress/
│   └── students/
└── main.dart
```

Each feature follows:

```text
feature_name/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── cubit/
    ├── pages/
    └── widgets/
```

## Notes

- `courses/` is the most complete example feature and demonstrates the full clean architecture flow.
- `ApiService` is already prepared with request/error interceptors and token injection support for future API integration.
- Routing redirects users into the correct dashboard based on the authenticated role.
- Light and dark themes are configured around the requested deep blue brand color `#182243`.
