import 'dart:io';
import 'dart:convert';

void main() {
  final file = File('lib/main.dart');
  
  // Read as bytes and decode to avoid Invalid UTF8 exceptions stopping the string
  List<int> bytes = file.readAsBytesSync();
  String content = utf8.decode(bytes, allowMalformed: true);
  
  content = content.replaceAll('ÃƒÂ¡', 'á');
  content = content.replaceAll('ÃƒÂ©', 'é');
  content = content.replaceAll('ÃƒÂ³', 'ó');
  content = content.replaceAll('ÃƒÂº', 'ú');
  content = content.replaceAll('ÃƒÂ±', 'ñ');
  content = content.replaceAll('Ã‚Â¿', '¿');
  content = content.replaceAll('biometrÃƒÂa', 'biometría');
  content = content.replaceAll('DÃƒÂa', 'Día');
  content = content.replaceAll('dÃƒÂa', 'día');
  content = content.replaceAll('AÃƒÂ±adir', 'Añadir');
  content = content.replaceAll('GestiÃƒÂ³n', 'Gestión');
  
  // Also clean up any single ones remaining just in case
  content = content.replaceAll('Ã¡', 'á');
  content = content.replaceAll('Ã©', 'é');
  content = content.replaceAll('Ã³', 'ó');
  content = content.replaceAll('Ãº', 'ú');
  content = content.replaceAll('Ã±', 'ñ');
  content = content.replaceAll('Ã¿', '¿');
  
  file.writeAsStringSync(content);
  print('main.dart cleaned!');
}
