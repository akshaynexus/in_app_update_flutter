/// The type of update flow to use on Android.
enum AndroidUpdateType {
  /// Full-screen, blocking update the user must accept.
  immediate,

  /// Background download while the user continues using the app.
  flexible,
}

/// Configuration for [InAppUpdateFlutter].
///
/// Provides default values for all update operations so you don't need to
/// pass the same parameters on every call.
class UpdateConfig {
  /// The numeric App Store ID of your iOS app.
  ///
  /// Required on iOS for presenting the App Store product page via StoreKit.
  /// Found in your App Store Connect URL.
  final String? appStoreId;

  /// The App Store region to check for iOS updates (e.g., `"us"`, `"gb"`).
  ///
  /// If `null`, the default region is used.
  final String? iosAppStoreRegion;

  /// The default update type on Android.
  ///
  /// Used by [InAppUpdateFlutter.startUpdate] and [checkAndUpdate].
  /// Defaults to [AndroidUpdateType.immediate].
  final AndroidUpdateType androidUpdateType;

  const UpdateConfig({
    this.appStoreId,
    this.iosAppStoreRegion,
    this.androidUpdateType = AndroidUpdateType.immediate,
  });
}
