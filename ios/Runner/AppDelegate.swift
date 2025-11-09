import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    var apiKey: String? = nil
    
    // Try to load API key from Info.plist first (for production builds)
    if let infoPlistKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
       !infoPlistKey.isEmpty,
       !infoPlistKey.contains("$(GOOGLE_MAPS_API_KEY)"),
       !infoPlistKey.contains("your_") {
      apiKey = infoPlistKey
      print("✅ Google Maps API Key loaded from Info.plist")
    }
    
    // Try to load from .env file if not found in Info.plist
    if apiKey == nil || apiKey?.isEmpty == true {
      if let path = Bundle.main.path(forResource: ".env", ofType: nil),
         let content = try? String(contentsOfFile: path) {
        let lines = content.components(separatedBy: .newlines)
        for line in lines {
          if line.hasPrefix("GOOGLE_MAPS_API_KEY=") {
            let key = String(line.dropFirst("GOOGLE_MAPS_API_KEY=".count))
              .trimmingCharacters(in: .whitespaces)
            // Check if it's not a placeholder
            if !key.isEmpty && 
               !key.contains("your_") && 
               !key.contains("YOUR_") &&
               key != "your_google_maps_api_key_here" {
              apiKey = key
              print("✅ Google Maps API Key loaded from .env file")
              break
            } else {
              print("⚠️ WARNING: .env contains placeholder API key. Please update with your actual key.")
            }
          }
        }
      }
    }
    
    // Fallback to environment variable
    if (apiKey == nil || apiKey?.isEmpty == true) {
      if let envKey = ProcessInfo.processInfo.environment["GOOGLE_MAPS_API_KEY"],
         !envKey.isEmpty,
         !envKey.contains("your_") {
        apiKey = envKey
        print("✅ Google Maps API Key loaded from environment variable")
      }
    }
    
    // Initialize Google Maps with API key
    if let key = apiKey, !key.isEmpty {
      GMSServices.provideAPIKey(key)
      print("✅ Google Maps SDK initialized successfully")
    } else {
      print("❌ ERROR: GOOGLE_MAPS_API_KEY not found or is a placeholder!")
      print("   Please set a valid API key in Info.plist (GMSApiKey) or .env file")
      print("   Maps will not work without a valid API key")
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
