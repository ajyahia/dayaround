import 'package:flutter/services.dart';

/// Controller for Win32 Desktop Window features (Always on Top, Window Resizing).
class WindowController {
  static const MethodChannel _channel = MethodChannel('jimy/window');

  /// Toggles whether the application window stays permanently on top of all other windows.
  static Future<void> setAlwaysOnTop(bool alwaysOnTop) async {
    try {
      await _channel.invokeMethod('setAlwaysOnTop', {'alwaysOnTop': alwaysOnTop});
    } catch (_) {}
  }

  /// Changes the native window size (e.g. for compact daily widget mode).
  static Future<void> setWindowSize({required int width, required int height}) async {
    try {
      await _channel.invokeMethod('setWindowSize', {'width': width, 'height': height});
    } catch (_) {}
  }
}
