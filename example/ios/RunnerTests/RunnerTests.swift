import Flutter
import UIKit
import XCTest

@testable import in_app_update_flutter

class RunnerTests: XCTestCase {

  func testShowStoreUpdateWithoutArgs() {
    let plugin = InAppUpdateFlutterPlugin()

    let call = FlutterMethodCall(methodName: "showStoreUpdate", arguments: nil)

    let resultExpectation = expectation(description: "result block must be called.")
    plugin.handle(call) { result in
      // Without valid arguments, the plugin should return FlutterMethodNotImplemented
      XCTAssertEqual(result as? NSObject, FlutterMethodNotImplemented as NSObject)
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 1)
  }

  func testShowStoreUpdateIosWithNonNumericId() {
    let plugin = InAppUpdateFlutterPlugin()

    let call = FlutterMethodCall(methodName: "showStoreUpdateIos", arguments: ["appStoreId": "not-a-number"])

    let resultExpectation = expectation(description: "result block must be called.")
    plugin.handle(call) { result in
      // A non-numeric appStoreId must be rejected before reaching StoreKit.
      let error = result as? FlutterError
      XCTAssertEqual(error?.code, "INVALID_APP_STORE_ID")
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 1)
  }

  func testShowStoreUpdateIosWithoutAppStoreId() {
    let plugin = InAppUpdateFlutterPlugin()

    let call = FlutterMethodCall(methodName: "showStoreUpdateIos", arguments: nil)

    let resultExpectation = expectation(description: "result block must be called.")
    plugin.handle(call) { result in
      // Missing appStoreId fails the argument binding and is not implemented.
      XCTAssertEqual(result as? NSObject, FlutterMethodNotImplemented as NSObject)
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 1)
  }

  func testUnknownMethod() {
    let plugin = InAppUpdateFlutterPlugin()

    let call = FlutterMethodCall(methodName: "unknownMethod", arguments: nil)

    let resultExpectation = expectation(description: "result block must be called.")
    plugin.handle(call) { result in
      XCTAssertEqual(result as? NSObject, FlutterMethodNotImplemented as NSObject)
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 1)
  }

}
