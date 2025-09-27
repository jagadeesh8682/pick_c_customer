import 'package:flutter/material.dart';
import 'webview_screen.dart';

/// Rate Card Screen showing official Pick Cargo pricing URL
class RateCardScreen extends StatelessWidget {
  const RateCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WebViewScreen(
      url: 'https://pickcargo.in/RateCard/Mobile',
      title: 'Rate Card',
    );
  }
}
