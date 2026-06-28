import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Cliente HTTP centralizado.
/// Injeta o token JWT automaticamente em todas as requisições autenticadas.
class ApiClient {
  static const String _tokenKey = 'auth_token';

  // ── Token Management ──────────────────────────────────────────────────────

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // ── Headers ───────────────────────────────────────────────────────────────

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Map<String, String> get _publicHeaders => {
    'Content-Type': 'application/json',
  };

  // ── HTTP Methods ──────────────────────────────────────────────────────────

  static Future<http.Response> get(String path, {bool auth = true}) async {
    final headers = auth ? await _authHeaders() : _publicHeaders;
    return http.get(
      Uri.parse('${AppConstants.baseUrl}$path'),
      headers: headers,
    );
  }

  static Future<http.Response> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    final headers = auth ? await _authHeaders() : _publicHeaders;
    return http.post(
      Uri.parse('${AppConstants.baseUrl}$path'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> patch(
    String path,
    Map<String, dynamic> body,
  ) async {
    final headers = await _authHeaders();
    return http.patch(
      Uri.parse('${AppConstants.baseUrl}$path'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  // ── Response Helpers ──────────────────────────────────────────────────────

  static Map<String, dynamic> parseResponse(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }
    throw ApiException(
      message: decoded['error'] ?? 'Erro desconhecido',
      statusCode: response.statusCode,
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  const ApiException({required this.message, required this.statusCode});

  @override
  String toString() => message;
}
