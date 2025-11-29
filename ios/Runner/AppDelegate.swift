import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Initialize Google Maps with API key from environment or Info.plist
    if let googleMapsApiKey = Bundle.main.object(forInfoDictionaryKey: "GoogleMapsApiKey") as? String {
      GMSServices.provideAPIKey(googleMapsApiKey)
    } else {
      // Fallback - replace with your actual API key for development
      GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
