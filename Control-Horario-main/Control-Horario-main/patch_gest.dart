import 'dart:io';

void main() {
  final file = File('lib/gestion_page.dart');
  String content = file.readAsStringSync();

  // 1. Add state for selected day and make dummy data update based on the day
  content = content.replaceFirst('  // Mock Data\n  List<Map<String, dynamic>> shifts = [', '''  int _selectedDay = 18;
  
  // Method to load mock data based on day
  void _changeDay(int day) {
    setState(() {
      _selectedDay = day;
      if (day == 16) {
        shifts = [
          {'id': 's1', 'time': '07:00 - 15:00', 'role': 'Recepcionista', 'location': 'Entrada Principal', 'urgency': 'Alta', 'urgencyColor': AppColors.dangerRed, 'assignedTo': null},
          {'id': 's2', 'time': '12:00 - 20:00', 'role': 'Asistente', 'location': 'Planta 2', 'urgency': 'Media', 'urgencyColor': AppColors.warningOrange, 'assignedTo': null},
        ];
        employees = [
          {'name': 'Juan P.', 'initials': 'JP', 'available': true, 'color': AppColors.primaryTealLight},
          {'name': 'Lucía R.', 'initials': 'LR', 'available': true, 'color': AppColors.warningOrange},
        ];
      } else if (day == 17) {
        shifts = [
          {'id': 's3', 'time': '10:00 - 18:00', 'role': 'Desarrollador', 'location': 'Remoto', 'urgency': 'Baja', 'urgencyColor': AppColors.successGreen, 'assignedTo': null},
        ];
        employees = [
          {'name': 'Ana G.', 'initials': 'AG', 'available': true, 'color': AppColors.accentCoral},
          {'name': 'Pedro S.', 'initials': 'PS', 'available': false, 'color': AppColors.successGreen},
        ];
      } else {
        shifts = [
          {'id': 'shift1', 'time': '08:00 - 16:00', 'role': 'Desarrollador', 'location': 'Oficina Central', 'urgency': 'Alta', 'urgencyColor': AppColors.dangerRed, 'assignedTo': null},
          {'id': 'shift2', 'time': '14:00 - 22:00', 'role': 'Soporte TI', 'location': 'Remoto', 'urgency': 'Baja', 'urgencyColor': AppColors.successGreen, 'assignedTo': null},
          {'id': 'shift3', 'time': '09:00 - 18:00', 'role': 'Jefe de Proyecto', 'location': 'Sala de Juntas', 'urgency': 'Media', 'urgencyColor': AppColors.warningOrange, 'assignedTo': null},
        ];
        employees = [
          {'name': 'Ana G.', 'initials': 'AG', 'available': true, 'color': AppColors.accentCoral},
          {'name': 'Carlos M.', 'initials': 'CM', 'available': true, 'color': AppColors.primaryTealLight},
          {'name': 'Lucía R.', 'initials': 'LR', 'available': false, 'color': AppColors.warningOrange},
          {'name': 'Pedro S.', 'initials': 'PS', 'available': true, 'color': AppColors.successGreen},
        ];
      }
    });
  }

  // Mock Data (Initial state represents day 18)
  List<Map<String, dynamic>> shifts = [''');

  content = content.replaceFirst('  final List<Map<String, dynamic>> employees = [', '  List<Map<String, dynamic>> employees = [');

  // 2. Make _buildWeekStrip use dynamic mapping
  final strWeekStrip = '''  Widget _buildWeekStrip() {
    final days = [
      {'short': 'Lun', 'num': 16},
      {'short': 'Mar', 'num': 17},
      {'short': 'Mié', 'num': 18},
      {'short': 'Jue', 'num': 19},
      {'short': 'Vie', 'num': 20},
    ];
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: days.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final d = days[index];
          final dayNum = d['num'] as int;
          return _buildDayCard(
            d['short'] as String,
            dayNum.toString(),
            _selectedDay == dayNum,
            () => _changeDay(dayNum),
          );
        },
      ),
    );
  }''';

  // Replace _buildWeekStrip
  content = content.replaceFirst(RegExp(r'  Widget _buildWeekStrip\(\) \{.*?(?=  Widget _buildDayCard)', dotAll:true), strWeekStrip + '\n\n');
  
  // 3. Update _buildDayCard
  content = content.replaceFirst('  Widget _buildDayCard(String day, String number, bool isSelected) {', '  Widget _buildDayCard(String day, String number, bool isSelected, VoidCallback onTap) {');
  content = content.replaceFirst('    return Container(', '    return GestureDetector(\n      onTap: onTap,\n      child: Container(');
  content = content.replaceFirst('      child: Column(', '      child: Column('); // No need to adjust closing braces if we just use GestureDetector
  // Actually, I need to make sure the GestureDetector wraps the Container gracefully.
  content = content.replaceFirst(RegExp(r'    return GestureDetector\(\\n      onTap: onTap,\n      child: Container\('), '    return GestureDetector(onTap: onTap, child: Container(');
  
  // 4. Fixing "Miï¿½" and things that got messed up in gestion_page.dart
  content = content.replaceAll('Miï¿½', 'Mié');

  file.writeAsStringSync(content);
  print('done');
}
