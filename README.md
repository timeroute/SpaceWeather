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
| Push / PR to `main` | Matrix build, upload artifacts |
| Published Release | Same builds, attach packages to the Release |
| Manual (`workflow_dispatch`) | Same as push |

| Target | Runner | Artifact |
|--------|--------|----------|
| Linux x64 | `ubuntu-22.04` | `space_weather-<ver>-linux-x64.tar.gz` |
| Windows x64 | `windows-latest` | `space_weather-<ver>-windows-x64.zip` |
| macOS Apple Silicon | `macos-latest` (arm64) | `space_weather-<ver>-macos-arm64.zip` |
| macOS Intel | `macos-15-intel` (x86_64) | `space_weather-<ver>-macos-x86_64.zip` |

> Note: GitHub plans to retire Intel macOS runners after macOS 15 (~Fall 2027). Prefer `macos-arm64` for new machines.

Release example:

```bash
git tag v1.0.0
git push origin v1.0.0
# Publish a GitHub Release for that tag — CI attaches the builds
```
