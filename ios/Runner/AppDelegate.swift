import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "app_receipt_channel", binaryMessenger: controller.binaryMessenger)

    channel.setMethodCallHandler { (call, result) in
        if call.method == "getAppReceipt" {
            if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
                let receiptData = try? Data(contentsOf: appStoreReceiptURL){
                let receiptString = receiptData.base64EncodedString(options:[])
                result(receiptString)
                } else{
                result(FlutterError(code: "NO_RECEIPT", message: "No receipt found", details: nil))
                }
            }   else {
            result(FlutterMethodNotImplemented)
            }
        }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
