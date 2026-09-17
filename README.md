# space_weather

Space Weather Situational Awareness — Sun-to-Earth chain visualization (Flutter).

## Getting Started

```bash
flutter pub get
flutter run -d linux
```

## App icon

Source art: `assets/branding/app_icon.png`

One-shot generator ([flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons)):

```bash
dart run flutter_launcher_icons
```

Config: `flutter_launcher_icons.yaml` (Android / iOS / Web / Windows / macOS).  
Linux window icon is wired in `linux/runner/my_application.cc` from the same asset.
