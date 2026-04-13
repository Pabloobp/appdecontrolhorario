import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main.dart';

class GestionPage extends StatefulWidget {
  const GestionPage({super.key});

  @override
  State<GestionPage> createState() => _GestionPageState();
}

class _GestionPageState extends State<GestionPage> {
  final ScrollController _scrollController = ScrollController();

  int _selectedDay = 18;
  String _activeFilter = 'Todos';
  bool _isDragging = false;
  bool _isBottomPanelExpanded = true;

  List<Map<String, dynamic>> shifts = [];
  List<Map<String, dynamic>> employees = [];

  @override
  void initState() {
    super.initState();
    _changeDay(18);
  }

  void _changeDay(int day) {
    setState(() {
      _selectedDay = day;
      _activeFilter = 'Todos';
      if (day == 16) {
        shifts = [
          {
            'id': 's1',
            'time': '07:00 - 15:00',
            'role': 'Recepcionista',
            'location': 'Entrada Principal',
            'urgency': 'Alta',
            'urgencyColor': AppColors.dangerRed,
            'assignedTo': null,
          },
          {
            'id': 's2',
            'time': '12:00 - 20:00',
            'role': 'Asistente',
            'location': 'Planta 2',
            'urgency': 'Media',
            'urgencyColor': AppColors.warningOrange,
            'assignedTo': 'Lucía R.',
          },
        ];
        employees = [
          {
            'name': 'Juan P.',
            'initials': 'JP',
            'available': true,
            'color': AppColors.primaryTealLight,
            'role': 'Asistente',
          },
          {
            'name': 'Lucía R.',
            'initials': 'LR',
            'available': true,
            'color': AppColors.warningOrange,
            'role': 'Asistente',
          },
          {
            'name': 'Mario T.',
            'initials': 'MT',
            'available': true,
            'color': AppColors.successGreen,
            'role': 'Recepcionista',
          },
        ];
      } else if (day == 17) {
        shifts = [
          {
            'id': 's3',
            'time': '10:00 - 18:00',
            'role': 'Desarrollador',
            'location': 'Remoto',
            'urgency': 'Baja',
            'urgencyColor': AppColors.successGreen,
            'assignedTo': null,
          },
        ];
        employees = [
          {
            'name': 'Ana G.',
            'initials': 'AG',
            'available': true,
            'color': AppColors.accentCoral,
            'role': 'Desarrollador',
          },
          {
            'name': 'Pedro S.',
            'initials': 'PS',
            'available': false,
            'color': AppColors.successGreen,
            'role': 'Desarrollador',
          },
        ];
      } else {
        shifts = [
          {
            'id': 'shift1',
            'time': '08:00 - 16:00',
            'role': 'Desarrollador',
            'location': 'Oficina Central',
            'urgency': 'Alta',
            'urgencyColor': AppColors.dangerRed,
            'assignedTo': null,
          },
          {
            'id': 'shift2',
            'time': '14:00 - 22:00',
            'role': 'Soporte TI',
            'location': 'Remoto',
            'urgency': 'Baja',
            'urgencyColor': AppColors.successGreen,
            'assignedTo': null,
          },
          {
            'id': 'shift3',
            'time': '09:00 - 18:00',
            'role': 'Jefe de Proyecto',
            'location': 'Sala de Juntas',
            'urgency': 'Media',
            'urgencyColor': AppColors.warningOrange,
            'assignedTo': null,
          },
        ];
        employees = [
          {
            'name': 'Ana G.',
            'initials': 'AG',
            'available': true,
            'color': AppColors.accentCoral,
            'role': 'Desarrollador',
          },
          {
            'name': 'Carlos M.',
            'initials': 'CM',
            'available': true,
            'color': AppColors.primaryTealLight,
            'role': 'Soporte TI',
          },
          {
            'name': 'Lucía R.',
            'initials': 'LR',
            'available': false,
            'color': AppColors.warningOrange,
            'role': 'Jefe de Proyecto',
          },
          {
            'name': 'Pedro S.',
            'initials': 'PS',
            'available': true,
            'color': AppColors.successGreen,
            'role': 'Desarrollador',
          },
          {
            'name': 'Sofia K.',
            'initials': 'SK',
            'available': true,
            'color': AppColors.primaryTeal,
            'role': 'Jefe de Proyecto',
          },
        ];
      }
    });
  }

  bool _isEmployeeAssigned(String employeeName) {
    return shifts.any((shift) => shift['assignedTo'] == employeeName);
  }

  bool _allShiftsAssigned() {
    if (shifts.isEmpty) return true;
    return shifts.every((shift) => shift['assignedTo'] != null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Gestión de Turnos',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryTealLight.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.primaryTealLight),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCalendarHeader(),
                  const SizedBox(height: 24),
                  _buildWeekStrip(),
                  const SizedBox(height: 32),
                  _buildSectionHeader(
                    'Turnos',
                    Icons.touch_app,
                    'Arrastra para asignar',
                  ),
                  const SizedBox(height: 24),

                  // Estado visual vacío o completo
                  if (_allShiftsAssigned() && shifts.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.successGreen.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.successGreen.withValues(
                                alpha: 0.15,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.celebration,
                              color: AppColors.successGreen,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '¡Todo cubierto!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Todos los turnos de hoy están asignados. Excelente trabajo.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (shifts.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.primaryTealLight.withValues(
                                  alpha: 0.05,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.event_available,
                                size: 48,
                                color: AppColors.primaryTealLight.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Día libre',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No hay turnos creados para hoy.',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  ...shifts.map((shift) => _buildShiftTarget(shift)),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          _isBottomPanelExpanded = !_isBottomPanelExpanded;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Personal Disponible',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.2,
                            ),
                          ),
                          Icon(
                            _isBottomPanelExpanded
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_up,
                            color: AppColors.textPrimary,
                          ),
                        ],
                      ),
                    ),
                    if (_isBottomPanelExpanded) ...[
                      const SizedBox(height: 16),
                      _buildFilters(),
                      const SizedBox(height: 24),

                      // Lista de Empleados
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        child: Row(
                          children: employees
                              .where((emp) {
                                bool belongsToRole =
                                    _activeFilter == 'Todos' ||
                                    emp['role'] == _activeFilter;
                                return belongsToRole &&
                                    !_isEmployeeAssigned(emp['name']);
                              })
                              .map((emp) {
                                bool isAvailable = emp['available'];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Draggable<Map<String, dynamic>>(
                                    data: emp,
                                    maxSimultaneousDrags: isAvailable
                                        ? 1
                                        : 0, // Desactiva arrastre si no está disponible
                                    onDragStarted: () {
                                      HapticFeedback.lightImpact();
                                      setState(() => _isDragging = true);
                                    },
                                    onDragEnd: (details) {
                                      setState(() => _isDragging = false);
                                    },
                                    feedback: Material(
                                      color: Colors.transparent,
                                      child: Transform.scale(
                                        scale: 1.1,
                                        child: _buildAvatarContent(
                                          emp,
                                          true,
                                          isHovering: true,
                                        ),
                                      ),
                                    ),
                                    childWhenDragging: Opacity(
                                      opacity: 0.3,
                                      child: _buildAvatarContent(emp, true),
                                    ),
                                    child: Opacity(
                                      opacity: isAvailable ? 1.0 : 0.5,
                                      child: _buildAvatarContent(emp, true),
                                    ),
                                  ),
                                );
                              })
                              .toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: 0.2,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryTealLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primaryTealLight),
              const SizedBox(width: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primaryTealLight,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    List<String> roles = ['Todos'];
    for (var emp in employees) {
      if (!roles.contains(emp['role']) && emp['role'] != null) {
        roles.add(emp['role']);
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: roles.map((role) {
          bool isSelected = _activeFilter == role;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _activeFilter = role);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryTeal : AppColors.surface,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryTeal
                        : AppColors.border.withValues(alpha: 0.5),
                    width: 0.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryTeal.withValues(
                              alpha: 0.25,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  role,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                    color: isSelected
                        ? AppColors.surface
                        : AppColors.textSecondary.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildShiftTarget(Map<String, dynamic> shift) {
    bool isAssigned = shift['assignedTo'] != null;

    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (details) =>
          !isAssigned && (details.data['available'] == true),
      onAcceptWithDetails: (details) {
        HapticFeedback.heavyImpact();
        final data = details.data;
        setState(() {
          shift['assignedTo'] = data['name'];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${data['name']} asignado a ${shift['role']}'),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
      builder: (context, candidateData, rejectedData) {
        bool isHovering = candidateData.isNotEmpty;
        Color urgencyColor = shift['urgencyColor'];

        Color baseBg = AppColors.surface;
        if (isAssigned) {
          baseBg = AppColors.successGreen.withValues(alpha: 0.05);
        } else if (isHovering) {
          baseBg = AppColors.primaryTealLight.withValues(alpha: 0.1);
        } else if (_isDragging && !isAssigned) {
          baseBg = urgencyColor.withValues(alpha: 0.02);
        }

        Color borderColor = AppColors.border.withValues(alpha: 0.5);
        if (isAssigned) {
          borderColor = AppColors.successGreen.withValues(alpha: 0.5);
        } else if (isHovering) {
          borderColor = AppColors.primaryTealLight;
        } else if (_isDragging && !isAssigned) {
          borderColor = urgencyColor.withValues(alpha: 0.3);
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: baseBg,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: isAssigned
                    ? AppColors.successGreen.withValues(alpha: 0.04)
                    : (isHovering
                          ? AppColors.primaryTealLight.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.04)),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: borderColor,
              width: isHovering || isAssigned || (_isDragging && !isAssigned)
                  ? 1.5
                  : 0.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isAssigned
                                ? Icons.check_circle
                                : Icons.access_time_filled,
                            size: 20,
                            color: isAssigned
                                ? AppColors.successGreen
                                : AppColors.textSecondary.withValues(
                                    alpha: 0.7,
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            shift['time'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      if (!isAssigned)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: urgencyColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: urgencyColor.withValues(alpha: 0.2),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            shift['urgency'],
                            style: TextStyle(
                              fontSize: 12,
                              color: urgencyColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(height: 1, thickness: 0.5),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shift['role'],
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            shift['location'],
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (isAssigned)
                        _buildAssignedPill(shift['assignedTo'], shift['id'])
                      else
                        _buildEmptySlot(isHovering, _isDragging, urgencyColor),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptySlot(
    bool isHovering,
    bool isDraggingGlobal,
    Color urgencyColor,
  ) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isHovering
              ? AppColors.primaryTealLight
              : (isDraggingGlobal
                    ? urgencyColor.withValues(alpha: 0.4)
                    : AppColors.border.withValues(alpha: 0.5)),
          style: BorderStyle.solid,
          width: isHovering || isDraggingGlobal ? 2 : 1,
        ),
        color: isHovering
            ? AppColors.primaryTealLight.withValues(alpha: 0.1)
            : (isDraggingGlobal
                  ? urgencyColor.withValues(alpha: 0.05)
                  : AppColors.surface),
        boxShadow: [
          if (!isHovering && !isDraggingGlobal)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Center(
        child: Icon(
          isDraggingGlobal ? Icons.touch_app : Icons.add_rounded,
          color: isHovering
              ? AppColors.primaryTealLight
              : (isDraggingGlobal
                    ? urgencyColor.withValues(alpha: 0.8)
                    : AppColors.textSecondary.withValues(alpha: 0.4)),
          size: 28,
        ),
      ),
    );
  }

  Widget _buildAssignedPill(String name, String shiftId) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          final shift = shifts.firstWhere((s) => s['id'] == shiftId);
          shift['assignedTo'] = null;
        });
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.5),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primaryTealLight.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, size: 16, color: AppColors.primaryTeal),
            ),
            const SizedBox(width: 12),
            Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.dangerRed.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 14,
                color: AppColors.dangerRed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarContent(
    Map<String, dynamic> emp,
    bool showStatus, {
    bool isHovering = false,
  }) {
    final bool available = emp['available'];
    final Color empColor = emp['color'] ?? AppColors.primaryTealLight;

    return Column(
      children: [
        Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isHovering ? 76 : 68,
              height: isHovering ? 76 : 68,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isHovering
                      ? empColor
                      : AppColors.border.withValues(alpha: 0.5),
                  width: isHovering ? 2.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: empColor.withValues(alpha: isHovering ? 0.2 : 0.05),
                    blurRadius: isHovering ? 20 : 12,
                    offset: Offset(0, isHovering ? 8 : 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: CircleAvatar(
                  backgroundColor: empColor.withValues(alpha: 0.15),
                  foregroundColor: empColor,
                  child: Text(
                    emp['initials'],
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: isHovering ? 22 : 18,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
            if (showStatus)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: available
                        ? AppColors.successGreen
                        : AppColors.textSecondary.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 3),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          emp['name'],
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            color: available
                ? AppColors.textPrimary
                : AppColors.textSecondary.withValues(alpha: 0.6),
            decoration: available
                ? TextDecoration.none
                : TextDecoration.lineThrough,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Marzo 2026',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: 0.3,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryTealLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_month_rounded,
                size: 18,
                color: AppColors.primaryTealLight,
              ),
              const SizedBox(width: 8),
              Text(
                'Semana 12',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primaryTealLight,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeekStrip() {
    final days = [
      {'short': 'Lun', 'num': 16},
      {'short': 'Mar', 'num': 17},
      {'short': 'Mié', 'num': 18},
      {'short': 'Jue', 'num': 19},
      {'short': 'Vie', 'num': 20},
    ];
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: days.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final d = days[index];
          final dayNum = d['num'] as int;
          return _buildDayCard(
            d['short'] as String,
            dayNum.toString(),
            _selectedDay == dayNum,
            () {
              HapticFeedback.selectionClick();
              _changeDay(dayNum);
            },
          );
        },
      ),
    );
  }

  Widget _buildDayCard(
    String day,
    String number,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 72,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryTealLight : AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primaryTealLight.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
          border: isSelected
              ? null
              : Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                  width: 0.5,
                ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day,
              style: TextStyle(
                fontSize: 13,
                color: isSelected
                    ? AppColors.surface.withValues(alpha: 0.9)
                    : AppColors.textSecondary.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              number,
              style: TextStyle(
                fontSize: 22,
                color: isSelected ? AppColors.surface : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
