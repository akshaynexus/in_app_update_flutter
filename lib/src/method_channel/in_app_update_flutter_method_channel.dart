import 'dart:io';

import 'package:flutter/services.dart';
import 'package:in_app_update_flutter/src/ios_update_check.dart';
import 'package:in_app_update_flutter/src/models/models.dart';

/// Handles platform communication via method channels for Android
/// and delegates to pure Dart for iOS update checks.
class MethodChannelInAppUpdateFlutter {
  static const MethodChannel _methodChannel = MethodChannel(
    'in_app_update_flutter',
  );

  static const EventChannel _eventChannel = EventChannel(
    'in_app_update_flutter/installStateAndroid',
  );

  Future<AppUpdateInfo> checkUpdate({String? iosAppStoreRegion}) async {
    if (Platform.isIOS) {
      final info = await checkUpdateIosImpl(iosAppStoreRegion: iosAppStoreRegion);
      return AppUpdateInfo.fromIos(info);
    } else if (Platform.isAndroid) {
      final info = await checkUpdateAndroid();
      return AppUpdateInfo.fromAndroid(info);
    }
    throw UnsupportedError('Unsupported platform');
  }

  Future<void> startUpdate({String? appStoreId}) async {
    if (Platform.isIOS) {
      if (appStoreId == null) {
        throw ArgumentError('appStoreId is required on iOS');
      }
      await showUpdateForIos(appStoreId: appStoreId);
    } else if (Platform.isAndroid) {
      await startImmediateUpdateAndroid();
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  @Deprecated(
    'Use showUpdateForIos() on iOS or checkUpdateAndroid() + '
    'startImmediateUpdateAndroid()/startFlexibleUpdateAndroid() on Android',
  )
  Future<void> showUpdate({required String appStoreId}) =>
      showUpdateForIos(appStoreId: appStoreId);

  Future<void> showUpdateForIos({required String appStoreId}) async {
    await _methodChannel.invokeMethod('showStoreUpdateIos', {
      'appStoreId': appStoreId,
    });
  }

  Future<AppUpdateInfoIos> checkUpdateIos({String? iosAppStoreRegion}) =>
      checkUpdateIosImpl(iosAppStoreRegion: iosAppStoreRegion);

  Future<AppUpdateInfoAndroid> checkUpdateAndroid() async {
    final result = await _methodChannel.invokeMapMethod<String, dynamic>(
      'checkForUpdateAndroid',
    );
    return AppUpdateInfoAndroid.fromMap(result!);
  }

  Future<UpdateResultAndroid> startImmediateUpdateAndroid({
    bool allowAssetPackDeletion = false,
  }) =>
      _startUpdateAndroid('startImmediateUpdateAndroid', allowAssetPackDeletion);

  Future<UpdateResultAndroid> startFlexibleUpdateAndroid({
    bool allowAssetPackDeletion = false,
  }) =>
      _startUpdateAndroid('startFlexibleUpdateAndroid', allowAssetPackDeletion);

  Future<UpdateResultAndroid> _startUpdateAndroid(
    String method,
    bool allowAssetPackDeletion,
  ) async {
    final result = await _methodChannel.invokeMethod<int>(
      method,
      {'allowAssetPackDeletion': allowAssetPackDeletion},
    );
    return UpdateResultAndroid.fromValue(result!);
  }

  Future<void> completeUpdateAndroid() async {
    await _methodChannel.invokeMethod<void>('completeUpdateAndroid');
  }

  Stream<InstallStateAndroid> get installStateStreamAndroid {
    return _eventChannel.receiveBroadcastStream().map((event) {
      return InstallStateAndroid.fromMap(
        Map<String, dynamic>.from(event as Map),
      );
    });
  }
}
