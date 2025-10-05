import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Load API key from .env file
    if let path = Bundle.main.path(forResource: ".env", ofType: nil),
       let content = try? String(contentsOfFile: path) {
      let lines = content.components(separatedBy: .newlines)
      for line in lines {
        if line.hasPrefix("GOOGLE_MAPS_API_KEY=") {
          let apiKey = String(line.dropFirst("GOOGLE_MAPS_API_KEY=".count))
          GMSServices.provideAPIKey(apiKey)
          print("✅ Google Maps API Key loaded from .env file")
          break
        }
      }
    } else {
      // Fallback to environment variable
      if let apiKey = ProcessInfo.processInfo.environment["GOOGLE_MAPS_API_KEY"] {
        GMSServices.provideAPIKey(apiKey)
        print("✅ Google Maps API Key loaded from environment variable")
      } else {
        print("⚠️ Warning: GOOGLE_MAPS_API_KEY not found in .env file or environment variables")
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
