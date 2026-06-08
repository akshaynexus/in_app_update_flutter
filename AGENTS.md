# AGENTS.md

## Project

Flutter plugin for in-app updates. iOS checks via iTunes Lookup API (pure Dart), shows App Store page via StoreKit. Android uses Play Core API (Kotlin native).

## Structure

```
lib/
  in_app_update_flutter.dart              # Public API, delegates to method channel
  src/
    method_channel/
      in_app_update_flutter_method_channel.dart  # Native method channel calls
    models/
      models.dart                         # Barrel export
      app_update_info.dart                # Unified cross-platform result
      app_update_info_ios.dart            # iOS-specific result
      app_update_info_android.dart        # Android-specific result (pre-existing)
      update_config.dart                  # UpdateConfig, AndroidUpdateType enum
      update_availability_android.dart    # Android availability enum (pre-existing)
      update_result_android.dart          # Android result enum (pre-existing)
      install_state_android.dart          # Android install state (pre-existing)
      install_status_android.dart         # Android install status enum (pre-existing)
    ios_update_check.dart                 # Pure Dart iTunes Lookup API call
android/                                  # Kotlin native (Play Core)
ios/                                      # Swift native (StoreKit presentation only)
test/                                     # Unit tests
```

## Key patterns

- `InAppUpdateFlutter` is the public entry point, takes optional `UpdateConfig`
- All methods delegate to `MethodChannelInAppUpdateFlutter`
- iOS update checking is pure Dart (`ios_update_check.dart`) — no native code
- iOS native code (`InAppUpdateFlutterPlugin.swift`) only handles `showStoreUpdateIos` (StoreKit)
- Android native code handles all Play Core methods
- `UpdateConfig` holds defaults: `appStoreId`, `iosAppStoreRegion`, `androidUpdateType`

## Commands

```bash
dart format lib/
flutter analyze
flutter test
```

Always run `dart format lib/` before committing.

## Dependencies

- `package_info_plus` — get installed version and bundle ID (used by iOS check)
- `pub_semver` — semantic version comparison (used by iOS check)
- No `plugin_platform_interface` — was removed, not needed

## Conventions

- Models use `const` constructors and factory methods
- Method channel methods are `snake_case` strings matching native side
- Deprecation via `@Deprecated` annotation, not removal
- Cross-platform methods (`checkUpdate`, `startUpdate`, `checkAndUpdate`) route via `Platform.isIOS`/`Platform.isAndroid`
