import 'dart:io';

void main() {
  final file = File('lib/main.dart');
  String content = file.readAsStringSync();
  
  content = content.replaceAll('Ã¡', 'á');
  content = content.replaceAll('Ã©', 'é');
  content = content.replaceAll('Ã³', 'ó');
  content = content.replaceAll('Ãº', 'ú');
  content = content.replaceAll('Ã±', 'ñ');
  content = content.replaceAll('biometrÃa', 'biometría');
  content = content.replaceAll('DÃa', 'Día');
  content = content.replaceAll('dÃa', 'día');
  content = content.replaceAll('AÃ±adir', 'Añadir');
  content = content.replaceAll('GestiÃ³n', 'Gestión');
  
  file.writeAsStringSync(content);
  print('main.dart fixed');
  
  final file2 = File('lib/gestion_page.dart');
  if (file2.existsSync()) {
    String content2 = file2.readAsStringSync();
    content2 = content2.replaceAll('Ã¡', 'á');
    content2 = content2.replaceAll('Ã©', 'é');
    content2 = content2.replaceAll('Ã³', 'ó');
    content2 = content2.replaceAll('Ãº', 'ú');
    content2 = content2.replaceAll('Ã±', 'ñ');
    file2.writeAsStringSync(content2);
    print('gestion_page.dart fixed');
  }
}
