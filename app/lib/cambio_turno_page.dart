import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'main.dart';
import 'services/supabase_service.dart';

class CambioTurnoPage extends StatefulWidget {
  const CambioTurnoPage({super.key});

  @override
  State<CambioTurnoPage> createState() => _CambioTurnoPageState();
}

class _CambioTurnoPageState extends State<CambioTurnoPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cambio de Turno'),
        backgroundColor: AppColors.background,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryTeal,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryTeal,
          tabs: const [
            Tab(text: 'Solicitar'),
            Tab(text: 'Recibidas'),
            Tab(text: 'Enviadas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _SolicitarCambioTab(),
          _SolicitudesRecibidasTab(),
          _SolicitudesEnviadasTab(),
        ],
      ),
    );
  }
}

// ── TAB: Solicitar cambio ─────────────────────────────────────────────────────

class _SolicitarCambioTab extends StatefulWidget {
  const _SolicitarCambioTab();

  @override
  State<_SolicitarCambioTab> createState() => _SolicitarCambioTabState();
}

class _SolicitarCambioTabState extends State<_SolicitarCambioTab> {
  bool _loading = true;
  List<Map<String, dynamic>> _empleados = [];
  Map<String, dynamic>? _empleadoSeleccionado;
  DateTime _fechaTurno = DateTime.now().add(const Duration(days: 1));
  bool _enviando = false;
  String? _mensaje;
  bool _exito = false;

  @override
  void initState() {
    super.initState();
    _cargarEmpleados();
  }

  Future<void> _cargarEmpleados() async {
    try {
      final empleados = await SupabaseService.getEmpleados();
      setState(() {
        _empleados = empleados;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaTurno,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _fechaTurno = picked);
  }

  Future<void> _enviarSolicitud() async {
    if (_empleadoSeleccionado == null) {
      setState(() { _mensaje = 'Selecciona un empleado'; _exito = false; });
      return;
    }
    setState(() { _enviando = true; _mensaje = null; });
    try {
      await SupabaseService.solicitarCambioTurno(
        usuarioNuevoId: _empleadoSeleccionado!['id'],
        fechaTurno: _fechaTurno,
      );
      setState(() {
        _mensaje = '¡Solicitud enviada correctamente!';
        _exito = true;
        _empleadoSeleccionado = null;
      });
    } catch (e) {
      setState(() {
        _mensaje = e.toString().replaceFirst('Exception: ', '');
        _exito = false;
      });
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Date picker card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fecha del turno a cambiar',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _seleccionarFecha,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.surface,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              color: AppColors.primaryTeal, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('EEEE, d MMMM yyyy', 'es_ES')
                                .format(_fechaTurno),
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.chevron_right,
                              color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Employee selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selecciona un empleado',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_empleados.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No hay otros empleados disponibles',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  else
                    ...(_empleados.map((emp) {
                      final isSelected =
                          _empleadoSeleccionado?['id'] == emp['id'];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryTeal.withValues(alpha: 0.08)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryTeal
                                : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primaryTeal
                                .withValues(alpha: 0.12),
                            child: Text(
                              '${emp['nombre']?[0] ?? '?'}',
                              style: TextStyle(
                                color: AppColors.primaryTeal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            '${emp['nombre'] ?? ''} ${emp['apellido'] ?? ''}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            emp['departamento'] ?? emp['rol'] ?? '',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle,
                                  color: AppColors.primaryTeal)
                              : null,
                          onTap: () {
                            setState(() => _empleadoSeleccionado = emp);
                          },
                        ),
                      );
                    })),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (_mensaje != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _exito
                    ? AppColors.successGreen.withValues(alpha: 0.1)
                    : AppColors.dangerRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _exito ? AppColors.successGreen : AppColors.dangerRed,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _exito ? Icons.check_circle : Icons.error_outline,
                    color: _exito ? AppColors.successGreen : AppColors.dangerRed,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _mensaje!,
                      style: TextStyle(
                        color: _exito
                            ? AppColors.successGreen
                            : AppColors.dangerRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _enviando ? null : _enviarSolicitud,
              icon: _enviando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send),
              label: Text(_enviando ? 'Enviando...' : 'Solicitar cambio'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── TAB: Solicitudes recibidas ────────────────────────────────────────────────

class _SolicitudesRecibidasTab extends StatefulWidget {
  const _SolicitudesRecibidasTab();

  @override
  State<_SolicitudesRecibidasTab> createState() =>
      _SolicitudesRecibidasTabState();
}

class _SolicitudesRecibidasTabState extends State<_SolicitudesRecibidasTab> {
  bool _loading = true;
  List<Map<String, dynamic>> _solicitudes = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final data = await SupabaseService.getCambiosTurnoRecibidos();
      if (mounted) setState(() { _solicitudes = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _responder(String id, bool aceptar) async {
    try {
      await SupabaseService.responderCambioTurno(
          cambioId: id, aceptar: aceptar);
      await _cargar();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(aceptar ? 'Solicitud aceptada' : 'Solicitud rechazada'),
            backgroundColor:
                aceptar ? AppColors.successGreen : AppColors.dangerRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_solicitudes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined,
                size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'No tienes solicitudes recibidas',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _solicitudes.length,
        itemBuilder: (context, i) {
          final s = _solicitudes[i];
          final solicitante = s['usuarios'] as Map<String, dynamic>?;
          final estado = s['estado'] as String? ?? 'pendiente';
          final isPendiente = estado == 'pendiente';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            AppColors.primaryTeal.withValues(alpha: 0.1),
                        child: Text(
                          '${solicitante?['nombre']?[0] ?? '?'}',
                          style: TextStyle(
                            color: AppColors.primaryTeal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${solicitante?['nombre'] ?? ''} ${solicitante?['apellido'] ?? ''}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Turno: ${s['fecha_turno'] ?? ''}',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      _EstadoChip(estado: estado),
                    ],
                  ),
                  if (isPendiente) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _responder(s['id'], false),
                            icon: const Icon(Icons.close),
                            label: const Text('Rechazar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.dangerRed,
                              side: BorderSide(color: AppColors.dangerRed),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _responder(s['id'], true),
                            icon: const Icon(Icons.check),
                            label: const Text('Aceptar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.successGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── TAB: Solicitudes enviadas ─────────────────────────────────────────────────

class _SolicitudesEnviadasTab extends StatefulWidget {
  const _SolicitudesEnviadasTab();

  @override
  State<_SolicitudesEnviadasTab> createState() =>
      _SolicitudesEnviadasTabState();
}

class _SolicitudesEnviadasTabState extends State<_SolicitudesEnviadasTab> {
  bool _loading = true;
  List<Map<String, dynamic>> _solicitudes = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final data = await SupabaseService.getCambiosTurnoEnviados();
      if (mounted) setState(() { _solicitudes = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_solicitudes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.send_outlined,
                size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'No has enviado solicitudes de cambio',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _solicitudes.length,
        itemBuilder: (context, i) {
          final s = _solicitudes[i];
          final destinatario = s['usuarios'] as Map<String, dynamic>?;
          final estado = s['estado'] as String? ?? 'pendiente';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.1),
                child: Text(
                  '${destinatario?['nombre']?[0] ?? '?'}',
                  style: TextStyle(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                '${destinatario?['nombre'] ?? ''} ${destinatario?['apellido'] ?? ''}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                'Turno: ${s['fecha_turno'] ?? ''}',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              trailing: _EstadoChip(estado: estado),
            ),
          );
        },
      ),
    );
  }
}

// ── Widget helper: chip de estado ─────────────────────────────────────────────

class _EstadoChip extends StatelessWidget {
  const _EstadoChip({required this.estado});
  final String estado;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (estado) {
      case 'aceptado':
        color = AppColors.successGreen;
        label = 'Aceptado';
        icon = Icons.check_circle;
        break;
      case 'rechazado':
        color = AppColors.dangerRed;
        label = 'Rechazado';
        icon = Icons.cancel;
        break;
      default:
        color = AppColors.warningOrange;
        label = 'Pendiente';
        icon = Icons.hourglass_empty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
