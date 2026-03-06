import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // In screenshot mode, skip Google Maps SDK initialization to prevent
    // the native location permission dialog from appearing before Flutter
    // renders. The sentinel file is created by tools/capture_screenshots.sh.
    let isScreenshotMode = FileManager.default.fileExists(
      atPath: "/tmp/.screenshot_mode"
    )
    if !isScreenshotMode {
      GMSServices.provideAPIKey("AIzaSyANjSd659Km7jqIW93ae1h-Gy1puDG-S_c")
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
