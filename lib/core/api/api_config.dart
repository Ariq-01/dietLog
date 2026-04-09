import 'dart:io';

class ApiConfig {
  ApiConfig._();

  /// Base URL untuk API
  /// - Android emulator: gunakan 10.0.2.2 untuk akses localhost host machine
  /// - iOS simulator: gunakan localhost
  /// - Physical device: gunakan IP address komputer di network yang sama
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    } else if (Platform.isIOS) {
      return 'http://localhost:3000';
    }
    // Fallback untuk web atau platform lain
    return 'http://localhost:3000';
  }
}
