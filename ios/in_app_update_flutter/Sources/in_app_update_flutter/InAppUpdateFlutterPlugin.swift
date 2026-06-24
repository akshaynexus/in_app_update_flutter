import UIKit
import Flutter
import StoreKit

public class InAppUpdateFlutterPlugin: NSObject, FlutterPlugin, SKStoreProductViewControllerDelegate {
  var flutterResult: FlutterResult?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "in_app_update_flutter", binaryMessenger: registrar.messenger())
    let instance = InAppUpdateFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  /// Resolves the view controller to present from at call time. Capturing the
  /// root view controller at registration is unreliable: on app launch the
  /// window/rootViewController may not be set yet (especially with scene-based
  /// lifecycles), leaving it nil for the lifetime of the plugin.
  private func topViewController() -> UIViewController? {
    let keyWindow = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }

    var top = keyWindow?.rootViewController
    while let presented = top?.presentedViewController {
      top = presented
    }
    return top
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "showStoreUpdateIos":
      guard let args = call.arguments as? [String: Any],
            let appStoreId = args["appStoreId"] as? String else {
        result(FlutterError(code: "BAD_ARGS", message: "appStoreId is required", details: nil))
        return
      }
      flutterResult = result
      showStoreProductView(appStoreId: appStoreId)
    case "checkUpdateIos":
      checkUpdate(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func checkUpdate(result: @escaping FlutterResult) {
    let bundleId = Bundle.main.bundleIdentifier ?? ""
    let installedVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""

    // Region comes from the device's language & region settings as an ISO
    // 3166-1 alpha-2 code (e.g. "us", "gb") — the same form the iTunes Lookup
    // API expects, so no conversion table is needed. Without a region the API
    // defaults to the US store, which would miss apps not listed there.
    let regionCode: String
    if #available(iOS 16, *) {
      regionCode = Locale.current.region?.identifier.lowercased() ?? ""
    } else {
      regionCode = Locale.current.regionCode?.lowercased() ?? ""
    }
    let regionPath = regionCode.isEmpty ? "" : "/\(regionCode)"

    func reply(_ storeVersion: String, _ updateAvailable: Bool) {
      let payload: [String: Any] = [
        "storeVersion": storeVersion,
        "installedVersion": installedVersion,
        "updateAvailable": updateAvailable,
        "bundleId": bundleId,
      ]
      DispatchQueue.main.async { result(payload) }
    }

    guard !bundleId.isEmpty,
          let encodedBundleId = bundleId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
          let url = URL(string: "https://itunes.apple.com\(regionPath)/lookup?bundleId=\(encodedBundleId)") else {
      reply("", false)
      return
    }

    let request = URLRequest(url: url, timeoutInterval: 10)
    URLSession.shared.dataTask(with: request) { data, _, _ in
      guard let data = data,
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let results = json["results"] as? [[String: Any]],
            let storeVersion = results.first?["version"] as? String else {
        reply("", false)
        return
      }
      // Only report an update when the installed version is known; an empty
      // installed version is non-comparable and must not be treated as stale.
      let updateAvailable = !installedVersion.isEmpty &&
        storeVersion.compare(installedVersion, options: .numeric) == .orderedDescending
      reply(storeVersion, updateAvailable)
    }.resume()
  }

  private func showStoreProductView(appStoreId: String) {
    // StoreKit requires the iTunes item identifier as an NSNumber. Passing a
    // String causes loadProduct(withParameters:) to silently fail (loaded == false,
    // error == nil), which surfaces as STORE_NOT_LOADED.
    guard let appStoreIdNumber = Int(appStoreId) else {
      flutterResult?(FlutterError(code: "INVALID_APP_STORE_ID", message: "appStoreId must be a numeric value", details: appStoreId))
      return
    }

    let productViewController = SKStoreProductViewController()
    productViewController.delegate = self

    let parameters = [SKStoreProductParameterITunesItemIdentifier : NSNumber(value: appStoreIdNumber)]

    productViewController.loadProduct(withParameters: parameters) { loaded, error in
      if let error = error {
        self.flutterResult?(FlutterError(code: "STORE_ERROR", message: "Failed to load product", details: error.localizedDescription))
        return
      }

      guard loaded else {
        self.flutterResult?(FlutterError(code: "STORE_NOT_LOADED", message: "Could not load product", details: nil))
        return
      }

      guard let vc = self.topViewController() else {
        self.flutterResult?(FlutterError(code: "NO_VIEW_CONTROLLER", message: "No view controller available to present the App Store overlay", details: nil))
        return
      }

      vc.present(productViewController, animated: true) {
        self.flutterResult?(nil)
      }
    }
  }

  public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
    viewController.dismiss(animated: true, completion: nil)
  }
}
