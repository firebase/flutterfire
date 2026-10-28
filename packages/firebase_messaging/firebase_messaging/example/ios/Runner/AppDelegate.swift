import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // UIScene registers plugins after this method returns. Apple requires the
    // UNUserNotificationCenter delegate to be set before launch completes.
    FLTFirebaseMessagingPlugin.configureNotificationCenterDelegate()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    // Only used by integration_test/e2e_test.dart.
    if let registrar = engineBridge.pluginRegistry.registrar(
      forPlugin: "RemoteNotificationTestChannel")
    {
      RemoteNotificationTestChannel.register(with: registrar)
    }
  }
}
