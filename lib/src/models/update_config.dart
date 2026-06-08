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

  const UpdateConfig({
    this.appStoreId,
    this.iosAppStoreRegion,
  });
}
