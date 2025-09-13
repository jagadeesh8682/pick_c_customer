import 'package:flutter/material.dart';

/// Global navigation service for navigating from anywhere in the app
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Navigate to a named route
  static Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate to a named route and remove all previous routes
  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String routeName, {
    Object? arguments,
    required RoutePredicate predicate,
  }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  /// Pop the current route
  static void pop<T extends Object?>([T? result]) {
    return navigatorKey.currentState!.pop<T>(result);
  }

  /// Pop until a specific route
  static void popUntil(RoutePredicate predicate) {
    return navigatorKey.currentState!.popUntil(predicate);
  }

  /// Check if navigator can pop
  static bool canPop() {
    return navigatorKey.currentState!.canPop();
  }
}
