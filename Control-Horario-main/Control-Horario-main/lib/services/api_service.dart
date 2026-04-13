import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// Excepción que se lanza cuando la API devuelve un error.
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

/// Servicio centralizado para comunicarse con el backend FastAPI.
class ApiService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _usernameKey = 'username';

  // ---------------------------------------------------------------------------
  // TOKEN / SESIÓN
  // ---------------------------------------------------------------------------

  static Future<String?> getToken() => _storage.read(key: _tokenKey);

  static Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  static Future<void> saveUsername(String username) =>
      _storage.write(key: _usernameKey, value: username);

  static Future<String?> getUsername() => _storage.read(key: _usernameKey);

  static Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _usernameKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ---------------------------------------------------------------------------
  // HEADERS
  // ---------------------------------------------------------------------------

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ---------------------------------------------------------------------------
  // AUTH
  // ---------------------------------------------------------------------------

  /// Inicia sesión y guarda el token en almacenamiento seguro.
  /// Devuelve el token de acceso.
  static Future<String> login(String username, String password) async {
    final uri = Uri.parse('${AppConfig.backendUrl}/login');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': username, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final token = data['access_token'] as String;
      await saveToken(token);
      await saveUsername(username);
      return token;
    }

    final detail = _extractDetail(response);
    throw ApiException(detail);
  }

  /// Crea un nuevo usuario en el backend.
  static Future<void> register(
    String username,
    String password,
    String empresa,
  ) async {
    final uri = Uri.parse('${AppConfig.backendUrl}/register');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'empresa': empresa,
      }),
    );

    if (response.statusCode == 200) return;
    final detail = _extractDetail(response);
    throw ApiException(detail);
  }

  /// Devuelve los datos del usuario autenticado.
  static Future<Map<String, dynamic>> getMe() async {
    final uri = Uri.parse('${AppConfig.backendUrl}/me');
    final response = await http.get(uri, headers: await _authHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw ApiException(_extractDetail(response));
  }

  // ---------------------------------------------------------------------------
  // FICHAJES
  // ---------------------------------------------------------------------------

  static Future<Map<String, dynamic>> ficharEntrada() async {
    final uri = Uri.parse('${AppConfig.backendUrl}/fichar-entrada');
    final response = await http.post(uri, headers: await _authHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw ApiException(_extractDetail(response));
  }

  static Future<Map<String, dynamic>> ficharSalida() async {
    final uri = Uri.parse('${AppConfig.backendUrl}/fichar-salida');
    final response = await http.post(uri, headers: await _authHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw ApiException(_extractDetail(response));
  }

  static Future<List<Map<String, dynamic>>> getHistorial() async {
    final uri = Uri.parse('${AppConfig.backendUrl}/ver-mi-historial');
    final response = await http.get(uri, headers: await _authHeaders());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(
        (data['historial'] as List).map((e) => Map<String, dynamic>.from(e)),
      );
    }
    throw ApiException(_extractDetail(response));
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  static String _extractDetail(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['detail']?.toString() ?? 'Error desconocido';
    } catch (_) {
      return 'Error ${response.statusCode}';
    }
  }
}
