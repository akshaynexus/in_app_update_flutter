import 'package:in_app_update_flutter/src/method_channel/in_app_update_flutter_method_channel.dart';
import 'package:in_app_update_flutter/src/models/models.dart';

export 'package:in_app_update_flutter/src/models/models.dart';

/// A Flutter plugin for in-app updates.
///
/// Use [checkUpdate] and [startUpdate] for a cross-platform experience,
/// or call platform-specific methods directly for more control.
class InAppUpdateFlutter {
  final _impl = MethodChannelInAppUpdateFlutter();

  /// Cross-platform: Checks whether an update is available.
  ///
  /// On iOS, queries the iTunes Lookup API. On Android, uses Play Core.
  /// Returns a unified [AppUpdateInfo] with platform-specific details.
  Future<AppUpdateInfo> checkUpdate({String? iosAppStoreRegion}) =>
      _impl.checkUpdate(iosAppStoreRegion: iosAppStoreRegion);

  /// Cross-platform: Starts the update flow.
  ///
  /// On iOS, presents the App Store product page via StoreKit
  /// ([appStoreId] is required).
  /// On Android, starts the immediate (blocking) update flow.
  Future<void> startUpdate({String? appStoreId}) =>
      _impl.startUpdate(appStoreId: appStoreId);

  /// Cross-platform: Checks for an update and starts the flow if available.
  ///
  /// Convenience method that combines [checkUpdate] and [startUpdate].
  /// Returns the [AppUpdateInfo] so you can inspect the result.
  Future<AppUpdateInfo> checkAndUpdate({
    String? iosAppStoreRegion,
    String? appStoreId,
  }) =>
      _impl.checkAndUpdate(
        iosAppStoreRegion: iosAppStoreRegion,
        appStoreId: appStoreId,
      );

  /// Shows the platform-specific in-app update UI.
  ///
  /// [appStoreId] is the numeric App Store ID of your app
  /// (found in your App Store Connect URL).
  @Deprecated(
    'Use showUpdateForIos() on iOS or checkUpdateAndroid() + '
    'startImmediateUpdateAndroid()/startFlexibleUpdateAndroid() on Android',
  )
  Future<void> showUpdate({required String appStoreId}) =>
      // ignore: deprecated_member_use_from_same_package
      _impl.showUpdate(appStoreId: appStoreId);

  /// iOS: Shows the App Store product page overlay via StoreKit.
  ///
  /// [appStoreId] is the numeric App Store ID of your app
  /// (found in your App Store Connect URL).
  Future<void> showUpdateForIos({required String appStoreId}) =>
      _impl.showUpdateForIos(appStoreId: appStoreId);

  /// iOS: Checks whether an update is available via the iTunes Lookup API.
  ///
  /// Queries the App Store for the latest published version and compares it
  /// against the currently installed version using semantic versioning.
  ///
  /// An optional [iosAppStoreRegion] can be provided to check a specific
  /// App Store region (e.g., `"us"`, `"gb"`).
  Future<AppUpdateInfoIos> checkUpdateIos({String? iosAppStoreRegion}) =>
      _impl.checkUpdateIos(iosAppStoreRegion: iosAppStoreRegion);

  /// Android: Checks whether an in-app update is available via Play Core.
  ///
  /// Returns an [AppUpdateInfoAndroid] containing update metadata such as
  /// availability, version code, priority, staleness, and allowed update types.
  Future<AppUpdateInfoAndroid> checkUpdateAndroid() =>
      _impl.checkUpdateAndroid();

  /// Android: Starts the immediate (full-screen, blocking) update flow.
  ///
  /// The user must accept the update to continue using the app. If the user
  /// closes the update screen, [UpdateResultAndroid.userCanceled] is returned.
  ///
  /// If [allowAssetPackDeletion] is `true`, the system may delete asset packs
  /// to free up storage for the update.
  Future<UpdateResultAndroid> startImmediateUpdateAndroid({
    bool allowAssetPackDeletion = false,
  }) =>
      _impl.startImmediateUpdateAndroid(
        allowAssetPackDeletion: allowAssetPackDeletion,
      );

  /// Android: Starts the flexible (background download) update flow.
  ///
  /// The update downloads in the background while the user continues
  /// using the app. Listen to [installStateStreamAndroid] for download
  /// progress, and call [completeUpdateAndroid] when the download is complete.
  ///
  /// If [allowAssetPackDeletion] is `true`, the system may delete asset packs
  /// to free up storage for the update.
  Future<UpdateResultAndroid> startFlexibleUpdateAndroid({
    bool allowAssetPackDeletion = false,
  }) =>
      _impl.startFlexibleUpdateAndroid(
        allowAssetPackDeletion: allowAssetPackDeletion,
      );

  /// Android: Completes a flexible update by triggering an app restart.
  ///
  /// Call this after [installStateStreamAndroid] reports
  /// [InstallStatusAndroid.downloaded].
  Future<void> completeUpdateAndroid() => _impl.completeUpdateAndroid();

  /// Android: A stream of install state changes during a flexible update.
  ///
  /// Emits [InstallStateAndroid] events with download progress and status.
  Stream<InstallStateAndroid> get installStateStreamAndroid =>
      _impl.installStateStreamAndroid;
}
