import "dart:io";
import "dart:convert";

void main() {
  final file = File("lib/gestion_page.dart");
  List<int> bytes = file.readAsBytesSync();
  String content = utf8.decode(bytes, allowMalformed: true);
  
  String rep = String.fromCharCode(0xFFFD);
  content = content.replaceAll("Mi$rep", "Mié");

  file.writeAsStringSync(content);
  print("Fixed weekday encoding issue!");
}
