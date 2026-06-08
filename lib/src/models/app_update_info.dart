import 'package:in_app_update_flutter/src/models/models.dart';

/// The detected platform for the current device.
enum AppPlatform { android, ios }

/// A unified cross-platform result from [checkUpdate].
///
/// Contains common update info regardless of platform, plus
/// platform-specific details when available.
class AppUpdateInfo {
  /// The detected platform.
  final AppPlatform platform;

  /// Whether an update is available.
  final bool updateAvailable;

  /// The currently installed version string.
  final String? installedVersion;

  /// The latest version available on the store.
  final String? storeVersion;

  /// Android-specific update info. `null` on iOS.
  final AppUpdateInfoAndroid? androidInfo;

  /// iOS-specific update info. `null` on Android.
  final AppUpdateInfoIos? iosInfo;

  const AppUpdateInfo({
    required this.platform,
    required this.updateAvailable,
    this.installedVersion,
    this.storeVersion,
    this.androidInfo,
    this.iosInfo,
  });

  /// Creates an [AppUpdateInfo] from an Android result.
  factory AppUpdateInfo.fromAndroid(AppUpdateInfoAndroid info) {
    return AppUpdateInfo(
      platform: AppPlatform.android,
      updateAvailable:
          info.updateAvailability == UpdateAvailabilityAndroid.updateAvailable,
      androidInfo: info,
    );
  }

  /// Creates an [AppUpdateInfo] from an iOS result.
  factory AppUpdateInfo.fromIos(AppUpdateInfoIos info) {
    return AppUpdateInfo(
      platform: AppPlatform.ios,
      updateAvailable: info.updateAvailable,
      installedVersion: info.installedVersion,
      storeVersion: info.storeVersion,
      iosInfo: info,
    );
  }

  @override
  String toString() =>
      'AppUpdateInfo(platform: $platform, updateAvailable: $updateAvailable, '
      'installed: $installedVersion, store: $storeVersion)';
}
