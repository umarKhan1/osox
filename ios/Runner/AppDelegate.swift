import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // IMPORTANT: Replace with your actual Google Maps API key
    // Do not commit your real key to version control for open-source safety.
    GMSServices.provideAPIKey("AIzaSyCC2ZpWTa2HUPEADVMu8Lg_c1YvWUGLuNE")
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
