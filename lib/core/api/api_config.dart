import 'dart:io';

class ApiConfig {
  ApiConfig._();

  /// Base URL untuk API
  /// 
  /// PENTING:
  /// - Android emulator: 10.0.2.2 (alias untuk localhost host)
  /// - iOS Simulator: localhost bekerja
  /// - Physical iOS device: HARUS menggunakan IP komputer di network yang sama
  /// 
  /// Untuk development, ganti IP di bawah dengan IP komputer Anda:
  /// - Mac/Linux: jalankan `ipconfig getifaddr en0` atau `hostname -I`
  /// - Windows: jalankan `ipconfig` di CMD
  /// 
  /// Untuk production, ganti dengan URL HTTPS backend Anda.
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    } else if (Platform.isIOS) {
      // iOS Simulator bisa pakai localhost
      // Physical iOS device HARUS pakai IP komputer (contoh: 192.168.1.100)
      // TODO: Ganti dengan IP komputer Anda untuk testing di physical device
      return 'http://localhost:3000';
    }
    // Fallback untuk web atau platform lain
    return 'http://localhost:3000';
  }
  
  /// Helper untuk set custom IP (untuk development di physical device)
  /// Usage: panggil di main() sebelum runApp()
  static String _customBaseUrl = '';
  static void setCustomBaseUrl(String ip, {int port = 3000}) {
    _customBaseUrl = 'http://$ip:$port';
  }
  
  /// Get base URL dengan priority ke custom URL jika diset
  static String get apiUrl {
    if (_customBaseUrl.isNotEmpty) return _customBaseUrl;
    return baseUrl;
  }
}
