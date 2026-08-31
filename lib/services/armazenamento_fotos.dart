import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class ArmazenamentoFotos {
  static Future<Directory> _pastaFotos() async {
    final docs = await getApplicationDocumentsDirectory();
    final pasta = Directory('${docs.path}/fotos_microscopio');
    if (!await pasta.exists()) {
      await pasta.create(recursive: true);
    }
    return pasta;
  }

  static Future<File> salvar(Uint8List bytes) async {
    final pasta = await _pastaFotos();
    final arquivo = File('${pasta.path}/foto_${DateTime.now().millisecondsSinceEpoch}.jpg');
    return arquivo.writeAsBytes(bytes);
  }

  static Future<List<File>> listar() async {
    final pasta = await _pastaFotos();
    final arquivos = pasta
        .listSync()
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.jpg'))
        .toList();
    arquivos.sort((a, b) => b.path.compareTo(a.path));
    return arquivos;
  }

  static Future<Directory> pastaVideosTemp() async {
    final tempDir = await getTemporaryDirectory();
    final pasta = Directory('${tempDir.path}/videos_microscopio');
    if (!await pasta.exists()) {
      await pasta.create(recursive: true);
    }
    return pasta;
  }
}
