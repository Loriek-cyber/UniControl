import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    if let controller = window?.rootViewController as? FlutterViewController {
        let systemBridgeChannel = FlutterMethodChannel(name: "com.unicontrol.app/system_bridge",
                                                  binaryMessenger: controller.binaryMessenger)
        
        systemBridgeChannel.setMethodCallHandler({
          [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            
          if call.method == "executeCommand" {
              guard let args = call.arguments as? [String: Any],
                    let command = args["command"] as? String else {
                  result(["status": "error", "message": "Invalid arguments"])
                  return
              }
              
              if command == "getMetrics" {
                  // TODO: Implement actual iOS system metric gathering here
                  UIDevice.current.isBatteryMonitoringEnabled = true
                  let response: [String: Any] = [
                      "status": "success",
                      "os": "iOS",
                      "battery": "\(UIDevice.current.batteryLevel * 100)%",
                      "message": "Mocked iOS Metrics"
                  ]
                  result(response)
              } else {
                  result(["status": "error", "message": "Unknown command"])
              }
          } else {
              result(FlutterMethodNotImplemented)
          }
        })
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
