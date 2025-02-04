import 'package:jio_webview/src/webview_controller.dart';

typedef OnUpiUrlDetected = void Function(String)?;

typedef OnPageError = void Function(String)?;

typedef NavigationDelegateHandler = Future<NavigationDecision> Function(
    NavigationRequest request)?;

class TypedefHandler {
  TypedefHandler(
      {this.onUpiUrlDetected,
      this.onPageError,
      this.navigationDelegateHandler});

  // Declare all variables for callbacks as follows

  // Declare a variable of the typedef type
  OnUpiUrlDetected onUpiUrlDetected;

  // Declare a variable of the typedef type
  OnPageError onPageError;

  NavigationDelegateHandler navigationDelegateHandler;

  void detectUrl(String url) {
    // Trigger the callback if it's not null
    onUpiUrlDetected?.call(url);
  }

  void handleError(String error) {
    // Trigger the callback if it's not null
    onPageError?.call(error);
  }

  // Method to simulate WebView navigation with a custom delegate
  Future<NavigationDecision> handleNavigation(NavigationRequest request) async {
    if (navigationDelegateHandler != null) {
      return await navigationDelegateHandler!(
          request); // Call the delegate handler if it's set
    } else {
      return NavigationDecision
          .navigate; // Default to navigating if no handler is set
    }
  }
}
