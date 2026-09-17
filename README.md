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
| Push / PR to `main` | Matrix build → **Actions Artifacts**（不在 Release 页） |
| Push tag `v*` | Build → **自动创建/更新 Release** 并挂上安装包 |
| Published Release | Build → 附件挂到该 Release |
| Manual (`workflow_dispatch`) | 同 push to main |

| Target | Runner | Artifact |
|--------|--------|----------|
| Linux x64 | `ubuntu-22.04` | `space_weather-<ver>-linux-x64.tar.gz` |
| Windows x64 | `windows-latest` | `space_weather-<ver>-windows-x64.zip` |
| macOS Apple Silicon | `macos-latest` (arm64) | `space_weather-<ver>-macos-arm64.zip` |
| macOS Intel | `macos-15-intel` (x86_64) | `space_weather-<ver>-macos-x86_64.zip` |

### 如何在 Release 页面看到编译产物

推荐方式（打 tag 自动发布）：

```bash
git push origin main
git tag v1.0.0
git push origin v1.0.0
```

然后打开 **GitHub → Releases → v1.0.0**。  
等 Actions 全部变绿后，Release 的 **Assets** 里会出现 4 个平台安装包。

备选：在 GitHub 上 **Releases → Draft a new release → Publish**，Actions 跑完后附件会自动挂上。

> 只 push 到 `main` 时，产物在 **Actions → 某次 run → Artifacts**，不会出现在 Release 页。

> Intel macOS runner 计划随 macOS 15 在 ~2027 退役，新机器优先用 `macos-arm64`。
