# space_weather

Space Weather Situational Awareness — Sun-to-Earth chain visualization (Flutter).

## Getting Started

```bash
flutter pub get
flutter run -d linux
```

## App icon

Source art: `assets/branding/app_icon.png`

```bash
dart run flutter_launcher_icons
```

Config: `flutter_launcher_icons.yaml` (Android / iOS / Web / Windows / macOS).  
Linux window icon is set in `linux/runner/my_application.cc`.

## CI / Desktop builds (GitHub Actions)

Workflow: [`.github/workflows/desktop.yml`](.github/workflows/desktop.yml)

| Trigger | Behavior |
|---------|----------|
| Push / PR to `main` | Matrix build **Linux + Windows**, upload artifacts |
| Published Release | Same builds, attach packages to the Release |
| Manual (`workflow_dispatch`) | Same as push |

Artifacts:

- Linux: `space_weather-<version>-linux-x64.tar.gz`
- Windows: `space_weather-<version>-windows-x64.zip`

Release example:

```bash
git tag v1.0.0
git push origin v1.0.0
# Publish a GitHub Release for that tag — CI attaches the builds
```
