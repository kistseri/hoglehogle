
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

    private var receiptChannel: FlutterMethodChannel?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        return super.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
    }

    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {

        GeneratedPluginRegistrant.register(
            with: engineBridge.pluginRegistry
        )

        let channel = FlutterMethodChannel(
            name: "app_receipt_channel",
            binaryMessenger: engineBridge.applicationRegistrar.messenger()
        )

        receiptChannel = channel

        channel.setMethodCallHandler { call, result in

            if call.method == "getAppReceipt" {

                if let receiptURL = Bundle.main.appStoreReceiptURL,
                   let receiptData = try? Data(contentsOf: receiptURL) {

                    result(receiptData.base64EncodedString(options: []))

                } else {

                    result(
                        FlutterError(
                            code: "NO_RECEIPT",
                            message: "No receipt found",
                            details: nil
                        )
                    )
                }

            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    }
}
