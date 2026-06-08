import 'dart:convert';
import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

import 'package:in_app_update_flutter/src/models/models.dart';

/// Checks for iOS App Store updates using the iTunes Lookup API.
/// Pure Dart — no native code or method channels required.
Future<AppUpdateInfoIos> checkUpdateIosImpl({String? iosAppStoreRegion}) async {
  final packageInfo = await PackageInfo.fromPlatform();
  final bundleId = packageInfo.packageName;
  final installedVersion = packageInfo.version;

  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final region = iosAppStoreRegion != null ? '$iosAppStoreRegion/' : '';
  final uri = Uri.parse(
    'https://itunes.apple.com/${region}lookup?bundleId=$bundleId&_=$timestamp',
  );

  final client = HttpClient();
  try {
    final request = await client.getUrl(uri);
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    final storeVersion =
        RegExp('"version":\\s*"([^"]*)"').firstMatch(responseBody)?.group(1);

    if (storeVersion == null) {
      return AppUpdateInfoIos(
        storeVersion: '',
        installedVersion: installedVersion,
        updateAvailable: false,
        bundleId: bundleId,
      );
    }

    bool updateAvailable = false;
    try {
      updateAvailable =
          Version.parse(storeVersion) > Version.parse(installedVersion);
    } on FormatException {
      // Invalid semver, updateAvailable stays false
    }

    return AppUpdateInfoIos(
      storeVersion: storeVersion,
      installedVersion: installedVersion,
      updateAvailable: updateAvailable,
      bundleId: bundleId,
    );
  } finally {
    client.close();
  }
}
