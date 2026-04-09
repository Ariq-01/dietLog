import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';

class ApiClient {
  ApiClient._();

  static final _client = http.Client();

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<dynamic> get(String path) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final response = await _client.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final response = await _client.post(
      uri,
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final response = await _client.put(
      uri,
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> delete(String path) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final response = await _client.delete(uri, headers: _headers);
    return _handleResponse(response);
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }
    throw ApiException(statusCode: response.statusCode, message: response.body);
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
