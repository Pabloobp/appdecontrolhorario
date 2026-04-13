import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class ApiService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  // ── Token helpers ──────────────────────────────────────────────────────────

  static Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  static Future<String?> getToken() => _storage.read(key: _tokenKey);

  static Future<void> deleteToken() => _storage.delete(key: _tokenKey);

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ── HTTP helpers ───────────────────────────────────────────────────────────

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Uri _url(String path) => Uri.parse('${AppConfig.backendUrl}$path');

  // ── Auth ───────────────────────────────────────────────────────────────────

  /// Login — devuelve el token JWT o lanza excepción con mensaje de error.
  static Future<String> login(String username, String password) async {
    final response = await http.post(
      _url('/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': username, 'password': password},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access_token'] as String;
      await saveToken(token);
      return token;
    }
    final detail = _extractDetail(response);
    throw Exception(detail);
  }

  /// Registro — lanza excepción si falla.
  static Future<void> register(String username, String password, String empresa) async {
    final response = await http.post(
      _url('/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password, 'empresa': empresa}),
    );
    if (response.statusCode != 200) {
      throw Exception(_extractDetail(response));
    }
  }

  /// Obtiene datos del usuario autenticado.
  static Future<Map<String, dynamic>> getMe() async {
    final response = await http.get(_url('/me'), headers: await _authHeaders());
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception(_extractDetail(response));
  }

  // ── Fichajes ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> ficharEntrada() async {
    final response = await http.post(_url('/fichar-entrada'), headers: await _authHeaders());
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception(_extractDetail(response));
  }

  static Future<Map<String, dynamic>> ficharSalida() async {
    final response = await http.post(_url('/fichar-salida'), headers: await _authHeaders());
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception(_extractDetail(response));
  }

  // ── Historial ──────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getHistorial() async {
    final response = await http.get(_url('/ver-mi-historial'), headers: await _authHeaders());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['historial']);
    }
    throw Exception(_extractDetail(response));
  }

  // ── Utilidades ─────────────────────────────────────────────────────────────

  static String _extractDetail(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return body['detail']?.toString() ?? 'Error ${response.statusCode}';
    } catch (_) {
      return 'Error ${response.statusCode}';
    }
  }
}
