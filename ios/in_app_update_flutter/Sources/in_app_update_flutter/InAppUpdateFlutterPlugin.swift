import UIKit
import Flutter
import StoreKit

public class InAppUpdateFlutterPlugin: NSObject, FlutterPlugin, SKStoreProductViewControllerDelegate {
  var flutterResult: FlutterResult?
  var controller: UIViewController?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "in_app_update_flutter", binaryMessenger: registrar.messenger())
    let instance = InAppUpdateFlutterPlugin()
    instance.controller = UIApplication.shared.delegate?.window??.rootViewController
    registrar.addMethodCallDelegate(instance, channel: channel)
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
    let productViewController = SKStoreProductViewController()
    productViewController.delegate = self

    let parameters = [SKStoreProductParameterITunesItemIdentifier : appStoreId]

    productViewController.loadProduct(withParameters: parameters) { loaded, error in
      if let error = error {
        self.flutterResult?(FlutterError(code: "STORE_ERROR", message: "Failed to load product", details: error.localizedDescription))
        return
      }

      if loaded, let vc = self.controller {
        vc.present(productViewController, animated: true) {
          self.flutterResult?(nil)
        }
      } else {
        self.flutterResult?(FlutterError(code: "STORE_NOT_LOADED", message: "Could not load product", details: nil))
      }
    }
  }

  public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
    viewController.dismiss(animated: true, completion: nil)
  }
}
