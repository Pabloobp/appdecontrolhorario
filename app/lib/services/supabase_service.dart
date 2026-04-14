import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  // ── Auth ───────────────────────────────────────────────────────────────────

  static Future<AuthResponse> login(String email, String password) {
    return client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<AuthResponse> register({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    String rol = 'empleado',
    String departamento = '',
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'nombre': nombre,
        'apellido': apellido,
        'rol': rol,
        'departamento': departamento,
      },
    );
    return response;
  }

  static Future<void> logout() => client.auth.signOut();

  static bool get isLoggedIn => client.auth.currentSession != null;

  static User? get currentUser => client.auth.currentUser;

  static String? get currentUserId => client.auth.currentUser?.id;

  // ── Perfil ─────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getPerfil() async {
    final userId = currentUserId;
    if (userId == null) return null;
    final response = await client
        .from('usuarios')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return response;
  }

  static Future<void> upsertPerfil(Map<String, dynamic> data) async {
    final userId = currentUserId;
    if (userId == null) return;
    await client.from('usuarios').upsert({'id': userId, ...data});
  }

  // ── Horarios ───────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getHorariosHoy() async {
    final userId = currentUserId;
    if (userId == null) return [];
    final diaSemana = DateTime.now().weekday % 7; // 0=domingo, 1=lun,...,6=sab
    final response = await client
        .from('horarios')
        .select()
        .eq('usuario_id', userId)
        .eq('dia_semana', diaSemana);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>> getAllHorarios() async {
    final userId = currentUserId;
    if (userId == null) return [];
    final response = await client
        .from('horarios')
        .select()
        .eq('usuario_id', userId)
        .order('dia_semana');
    return List<Map<String, dynamic>>.from(response);
  }

  // ── Marcajes ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getMarcajeHoy() async {
    final userId = currentUserId;
    if (userId == null) return null;
    final hoy = DateTime.now().toIso8601String().substring(0, 10);
    final response = await client
        .from('marcajes')
        .select()
        .eq('usuario_id', userId)
        .eq('fecha', hoy)
        .maybeSingle();
    return response;
  }

  static Future<void> ficharEntrada() async {
    final userId = currentUserId;
    if (userId == null) throw Exception('No hay sesión activa');
    final hoy = DateTime.now().toIso8601String().substring(0, 10);
    final ahora = DateTime.now().toUtc().toIso8601String();

    // Check if there's already an open check-in today
    final existing = await getMarcajeHoy();
    if (existing != null) {
      if (existing['hora_entrada'] != null && existing['hora_salida'] == null) {
        throw Exception('Ya tienes una jornada abierta hoy');
      }
      if (existing['hora_entrada'] != null && existing['hora_salida'] != null) {
        throw Exception('La jornada de hoy ya está completada');
      }
    }

    await client.from('marcajes').insert({
      'usuario_id': userId,
      'fecha': hoy,
      'hora_entrada': ahora,
    });
  }

  static Future<void> ficharSalida() async {
    final userId = currentUserId;
    if (userId == null) throw Exception('No hay sesión activa');
    final hoy = DateTime.now().toIso8601String().substring(0, 10);
    final ahora = DateTime.now().toUtc().toIso8601String();

    final existing = await getMarcajeHoy();
    if (existing == null || existing['hora_entrada'] == null) {
      throw Exception('No tienes una jornada abierta hoy');
    }
    if (existing['hora_salida'] != null) {
      throw Exception('Ya has fichado la salida hoy');
    }

    await client
        .from('marcajes')
        .update({'hora_salida': ahora})
        .eq('usuario_id', userId)
        .eq('fecha', hoy);
  }

  static Future<List<Map<String, dynamic>>> getMarcajesMes() async {
    final userId = currentUserId;
    if (userId == null) return [];
    final now = DateTime.now();
    final primerDia =
        DateTime(now.year, now.month, 1).toIso8601String().substring(0, 10);
    final ultimoDia =
        DateTime(now.year, now.month + 1, 0).toIso8601String().substring(0, 10);

    final response = await client
        .from('marcajes')
        .select()
        .eq('usuario_id', userId)
        .gte('fecha', primerDia)
        .lte('fecha', ultimoDia)
        .order('fecha', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>> getMarcajesRango(
    DateTime desde,
    DateTime hasta,
  ) async {
    final userId = currentUserId;
    if (userId == null) return [];
    final desdeStr = desde.toIso8601String().substring(0, 10);
    final hastaStr = hasta.toIso8601String().substring(0, 10);

    final response = await client
        .from('marcajes')
        .select()
        .eq('usuario_id', userId)
        .gte('fecha', desdeStr)
        .lte('fecha', hastaStr)
        .order('fecha', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // ── Cambios de turno ───────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getEmpleados() async {
    final userId = currentUserId;
    if (userId == null) return [];
    final response = await client
        .from('usuarios')
        .select('id, nombre, apellido, departamento, rol')
        .neq('id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> solicitarCambioTurno({
    required String usuarioNuevoId,
    required DateTime fechaTurno,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('No hay sesión activa');
    await client.from('cambios_turno').insert({
      'usuario_original_id': userId,
      'usuario_nuevo_id': usuarioNuevoId,
      'fecha_turno': fechaTurno.toIso8601String().substring(0, 10),
      'estado': 'pendiente',
    });
  }

  static Future<List<Map<String, dynamic>>> getCambiosTurnoRecibidos() async {
    final userId = currentUserId;
    if (userId == null) return [];
    final response = await client
        .from('cambios_turno')
        .select()
        .eq('usuario_nuevo_id', userId)
        .order('created_at', ascending: false);
    final cambios = List<Map<String, dynamic>>.from(response);

    // Enrich with solicitante info
    for (final cambio in cambios) {
      final solicitanteId = cambio['usuario_original_id'] as String?;
      if (solicitanteId != null) {
        final solicitante = await client
            .from('usuarios')
            .select('nombre, apellido')
            .eq('id', solicitanteId)
            .maybeSingle();
        cambio['usuarios'] = solicitante;
      }
    }
    return cambios;
  }

  static Future<List<Map<String, dynamic>>> getCambiosTurnoEnviados() async {
    final userId = currentUserId;
    if (userId == null) return [];
    final response = await client
        .from('cambios_turno')
        .select()
        .eq('usuario_original_id', userId)
        .order('created_at', ascending: false);
    final cambios = List<Map<String, dynamic>>.from(response);

    // Enrich with destinatario info
    for (final cambio in cambios) {
      final destinatarioId = cambio['usuario_nuevo_id'] as String?;
      if (destinatarioId != null) {
        final destinatario = await client
            .from('usuarios')
            .select('nombre, apellido')
            .eq('id', destinatarioId)
            .maybeSingle();
        cambio['usuarios'] = destinatario;
      }
    }
    return cambios;
  }

  static Future<void> responderCambioTurno({
    required String cambioId,
    required bool aceptar,
  }) async {
    await client
        .from('cambios_turno')
        .update({'estado': aceptar ? 'aceptado' : 'rechazado'})
        .eq('id', cambioId);
  }
}
