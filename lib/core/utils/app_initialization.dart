import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

/// Application initialization configuration
/// This file contains all the initialization logic for the app
class AppInitialization {
  /// Initialize all app dependencies
  static Future<void> initializeAll() async {
    // Ensure Flutter is initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Remove # from URL for cleaner URLs
    usePathUrlStrategy();

    // Initialize Firebase
    await Firebase.initializeApp();

    // Set up HTTP overrides for development
    HttpOverrides.global = MyHttpOverrides();
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
