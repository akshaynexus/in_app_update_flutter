# in_app_update_flutter

A Flutter plugin for in-app updates on both iOS and Android.

On **iOS**, it checks for updates via the iTunes Lookup API and presents the App Store product page using `SKStoreProductViewController` (StoreKit), keeping users inside the app during the update flow. On **Android**, it integrates with Google Play's In-App Updates API to support both immediate (blocking) and flexible (background) update flows.

---

## Screenshots

| iOS | Android Immediate | Android Flexible |
|-----|------------------|-----------------|
| ![iOS in-app update](https://raw.githubusercontent.com/axions-org/in_app_update_flutter/production/assets/screenshots/ios-in-app-update.png) | ![Android immediate update](https://raw.githubusercontent.com/axions-org/in_app_update_flutter/production/assets/screenshots/android-immediate-update.png) | ![Android flexible update](https://raw.githubusercontent.com/axions-org/in_app_update_flutter/production/assets/screenshots/android-flexible-update.png) |

---

## Features

- **iOS**: Check for updates via iTunes Lookup API (pure Dart, no native code)
- **iOS**: Show the App Store update prompt using `SKStoreProductViewController` without navigating users away from the app
- **iOS**: Native Swift implementation with zero AppDelegate configuration required
- **iOS**: Supports both Swift Package Manager (SPM) and CocoaPods
- **Android**: Check update availability and metadata via the Play Core API
- **Android**: Immediate update flow — full-screen, blocking prompt the user must accept
- **Android**: Flexible update flow — background download while the user continues using the app
- **Android**: Install state stream for monitoring flexible update download progress
- **Cross-platform**: Unified `checkUpdate()`, `startUpdate()`, and `checkAndUpdate()` APIs

---

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  in_app_update_flutter: ^2.0.3
```

Then run:

```bash
flutter pub get
```

---

## Setup

Create an `InAppUpdateFlutter` instance with an `UpdateConfig` to set your app's defaults:

### Both iOS and Android

```dart
import 'package:in_app_update_flutter/in_app_update_flutter.dart';

final updater = InAppUpdateFlutter(UpdateConfig(
  appStoreId: '1234567890',              // Required for iOS
  iosAppStoreRegion: 'us',               // Optional: specific App Store region
  androidUpdateType: AndroidUpdateType.flexible, // Optional: immediate (default) or flexible
));
```

### iOS only

```dart
final updater = InAppUpdateFlutter(UpdateConfig(
  appStoreId: '1234567890',
));
```

### Android only

```dart
final updater = InAppUpdateFlutter(UpdateConfig(
  androidUpdateType: AndroidUpdateType.flexible, // or .immediate (default)
));
```

---

## Quick Start

```dart
await updater.checkAndUpdate();
```

If an update is available, it starts the flow automatically using your config defaults.

---

## Usage

### Check for updates

```dart
final info = await updater.checkUpdate();

if (info.updateAvailable) {
  print('Update available: ${info.storeVersion}');
}
```

### Start the update flow

```dart
// On iOS: presents App Store page via StoreKit
// On Android: starts immediate (blocking) update
await updater.startUpdate();
```

### Per-call overrides

Config values can be overridden on any call:

```dart
await updater.checkUpdate(iosAppStoreRegion: 'gb');
await updater.startUpdate(appStoreId: '9876543210');
await updater.checkAndUpdate(
  iosAppStoreRegion: 'jp',
  appStoreId: '9876543210',
);
```

---

## iOS Details

Pass your numeric App Store ID to `showUpdateForIos` (or set it in `UpdateConfig`). The ID can be found in your App Store Connect URL or the app's public App Store link.

**How to find your App Store ID:**

1. Open your app's App Store URL — for example: `https://apps.apple.com/app/id1234567890`
2. The numeric portion after `id` is your App Store ID.

**iOS notes:**
- Requires iOS 12.0 or later
- Does not work on simulators
- Not supported in TestFlight builds — test on a real device using a development or App Store build

---

## Android Details

Android uses Google Play's In-App Updates API. The typical flow is:

1. Call `checkUpdateAndroid()` to retrieve update availability and metadata.
2. Based on the result, start either an immediate or flexible update.

### Immediate Update

An immediate update presents a full-screen prompt that the user must complete before continuing. Use this for critical updates.

```dart
final info = await updater.checkUpdateAndroid();

if (info.updateAvailability == UpdateAvailabilityAndroid.updateAvailable &&
    info.isImmediateUpdateAllowed) {
  final result = await updater.startImmediateUpdateAndroid();
  // result is UpdateResultAndroid.success or UpdateResultAndroid.userCanceled
}
```

### Flexible Update

A flexible update downloads in the background while the user continues using the app. When the download completes, call `completeUpdateAndroid()` to apply the update.

```dart
final info = await updater.checkUpdateAndroid();

if (info.updateAvailability == UpdateAvailabilityAndroid.updateAvailable &&
    info.isFlexibleUpdateAllowed) {
  await updater.startFlexibleUpdateAndroid();

  updater.installStateStreamAndroid.listen((state) {
    if (state.installStatus == InstallStatusAndroid.downloaded) {
      updater.completeUpdateAndroid();
    }
  });
}
```

### AppUpdateInfoAndroid fields

| Field | Type | Description |
|---|---|---|
| `updateAvailability` | `UpdateAvailabilityAndroid` | Whether an update is available |
| `availableVersionCode` | `int?` | Version code of the available update |
| `updatePriority` | `int` | Developer-assigned priority (0–5) |
| `clientVersionStalenessDays` | `int?` | Days since the update became available |
| `isImmediateUpdateAllowed` | `bool` | Whether immediate update is allowed |
| `isFlexibleUpdateAllowed` | `bool` | Whether flexible update is allowed |
| `installStatus` | `InstallStatusAndroid` | Current install status |

---

## Example

A complete working example is available in the [`example/`](example) directory.

```bash
cd example
flutter run
```

---

## License

[MIT License](LICENSE)

---

## Contributing

Pull requests and feedback are welcome. For major changes, please open an issue first to discuss what you would like to change.
