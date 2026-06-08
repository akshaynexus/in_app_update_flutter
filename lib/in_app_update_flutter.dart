import 'package:in_app_update_flutter/src/method_channel/in_app_update_flutter_method_channel.dart';
import 'package:in_app_update_flutter/src/models/models.dart';

export 'package:in_app_update_flutter/src/models/models.dart';

/// A Flutter plugin for in-app updates.
///
/// Create an instance with [UpdateConfig] to set defaults, then call
/// [checkUpdate], [startUpdate], or [checkAndUpdate].
///
/// ```dart
/// final updater = InAppUpdateFlutter(UpdateConfig(
///   appStoreId: '123456789',
///   iosAppStoreRegion: 'us',
/// ));
///
/// // Simple: check and update in one call
/// final info = await updater.checkAndUpdate();
///
/// // Or step by step
/// final info = await updater.checkUpdate();
/// if (info.updateAvailable) await updater.startUpdate();
/// ```
class InAppUpdateFlutter {
  final _impl = MethodChannelInAppUpdateFlutter();
  final UpdateConfig _config;

  /// Creates an [InAppUpdateFlutter] instance.
  ///
  /// If [config] is provided, its values are used as defaults for all
  /// operations. Per-call parameters always override config values.
  InAppUpdateFlutter([this._config = const UpdateConfig()]);

  /// Cross-platform: Checks whether an update is available.
  ///
  /// On iOS, queries the iTunes Lookup API. On Android, uses Play Core.
  /// Returns a unified [AppUpdateInfo] with platform-specific details.
  ///
  /// [iosAppStoreRegion] overrides [UpdateConfig.iosAppStoreRegion] if provided.
  Future<AppUpdateInfo> checkUpdate({String? iosAppStoreRegion}) =>
      _impl.checkUpdate(
        iosAppStoreRegion: iosAppStoreRegion ?? _config.iosAppStoreRegion,
      );

  /// Cross-platform: Starts the update flow.
  ///
  /// On iOS, presents the App Store product page via StoreKit.
  /// On Android, starts the update flow using [UpdateConfig.androidUpdateType]
  /// (default: immediate).
  ///
  /// [appStoreId] overrides [UpdateConfig.appStoreId] if provided.
  Future<void> startUpdate({String? appStoreId, AndroidUpdateType? androidUpdateType}) =>
      _impl.startUpdate(
        appStoreId: appStoreId ?? _config.appStoreId,
        androidUpdateType: androidUpdateType ?? _config.androidUpdateType,
      );

  /// Cross-platform: Checks for an update and starts the flow if available.
  ///
  /// Convenience method that combines [checkUpdate] and [startUpdate].
  /// On iOS, [appStoreId] (or [UpdateConfig.appStoreId]) is required.
  /// On Android, uses [UpdateConfig.androidUpdateType] by default.
  Future<void> checkAndUpdate({
    String? iosAppStoreRegion,
    String? appStoreId,
    AndroidUpdateType? androidUpdateType,
  }) =>
      _impl.checkAndUpdate(
        iosAppStoreRegion: iosAppStoreRegion ?? _config.iosAppStoreRegion,
        appStoreId: appStoreId ?? _config.appStoreId,
        androidUpdateType: androidUpdateType ?? _config.androidUpdateType,
      );

  /// Shows the platform-specific in-app update UI.
  @Deprecated(
    'Use showUpdateForIos() on iOS or checkUpdateAndroid() + '
    'startImmediateUpdateAndroid()/startFlexibleUpdateAndroid() on Android',
  )
  Future<void> showUpdate({required String appStoreId}) =>
      // ignore: deprecated_member_use_from_same_package
      _impl.showUpdate(appStoreId: appStoreId);

  /// iOS: Shows the App Store product page overlay via StoreKit.
  ///
  /// [appStoreId] overrides [UpdateConfig.appStoreId] if provided.
  Future<void> showUpdateForIos({String? appStoreId}) =>
      _impl.showUpdateForIos(
        appStoreId: appStoreId ?? _config.appStoreId ?? '',
      );

  /// iOS: Checks whether an update is available via the iTunes Lookup API.
  ///
  /// [iosAppStoreRegion] overrides [UpdateConfig.iosAppStoreRegion] if provided.
  Future<AppUpdateInfoIos> checkUpdateIos({String? iosAppStoreRegion}) =>
      _impl.checkUpdateIos(
        iosAppStoreRegion: iosAppStoreRegion ?? _config.iosAppStoreRegion,
      );

  /// Android: Checks whether an in-app update is available via Play Core.
  Future<AppUpdateInfoAndroid> checkUpdateAndroid() =>
      _impl.checkUpdateAndroid();

  /// Android: Starts the immediate (full-screen, blocking) update flow.
  Future<UpdateResultAndroid> startImmediateUpdateAndroid({
    bool allowAssetPackDeletion = false,
  }) =>
      _impl.startImmediateUpdateAndroid(
        allowAssetPackDeletion: allowAssetPackDeletion,
      );

  /// Android: Starts the flexible (background download) update flow.
  Future<UpdateResultAndroid> startFlexibleUpdateAndroid({
    bool allowAssetPackDeletion = false,
  }) =>
      _impl.startFlexibleUpdateAndroid(
        allowAssetPackDeletion: allowAssetPackDeletion,
      );

  /// Android: Completes a flexible update by triggering an app restart.
  Future<void> completeUpdateAndroid() => _impl.completeUpdateAndroid();

  /// Android: A stream of install state changes during a flexible update.
  Stream<InstallStateAndroid> get installStateStreamAndroid =>
      _impl.installStateStreamAndroid;
}
