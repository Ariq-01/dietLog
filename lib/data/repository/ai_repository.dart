import 'dart:convert';
import 'package:http/http.dart' as http;

class AiRepository {
  // PENTING: 
  // - Android Emulator: pakai 10.0.2.2 (BUKAN localhost)
  // - iOS Simulator: pakai localhost
  // - Physical device: pakai IP komputer kamu (contoh: 192.168.1.x)
  static const String _baseUrl = 'http://10.0.2.2:3000';
  
  final http.Client _client;

  AiRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> sendMessage(String message) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/chat');
      
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed: ${response.statusCode} - ${response.body}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
