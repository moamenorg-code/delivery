import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformService {
  static bool get isWeb => kIsWeb;
  static bool get isDesktop => !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);
  static bool get isMobile => !kIsWeb && (Platform.isIOS || Platform.isAndroid);
  
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isLinux => !kIsWeb && Platform.isLinux;

  static String get currentPlatform {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  static double get defaultPadding {
    if (isDesktop) return 16.0;
    if (isWeb) return 24.0;
    return 8.0;
  }

  static bool get supportsHapticFeedback => isMobile;
  static bool get supportsLocationServices => isMobile || isWeb;
  static bool get supportsFileSystem => !isWeb;
  static bool get supportsPushNotifications => isMobile || isWeb;
  
  static Map<String, dynamic> getPlatformSpecificSettings() {
    switch (currentPlatform) {
      case 'android':
        return {
          'minSdkVersion': 21,
          'targetSdkVersion': 33,
          'enableProguard': true,
          'enableR8': true,
          'enableMultiDex': true,
        };
      case 'ios':
        return {
          'minimumOSVersion': '13.0',
          'supportsBiometrics': true,
          'supportsLocationAlways': true,
        };
      case 'web':
        return {
          'enableServiceWorker': true,
          'enablePWA': true,
          'webRendererCanvasKit': true,
        };
      case 'windows':
        return {
          'enableWindowsUpdater': true,
          'supportsTrayIcon': true,
          'supportsAutoStart': true,
        };
      case 'macos':
        return {
          'enableSpotlight': true,
          'supportsTouchBar': true,
          'enableDockIcon': true,
        };
      case 'linux':
        return {
          'enableSystemTray': true,
          'supportsAppIndicator': true,
          'enableAutoStart': true,
        };
      default:
        return {};
    }
  }
}