import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Transforma uma foto capturada em algo parecido com uma digitalização de
/// documento: escala de cinza + mais contraste, para destacar texto/traços
/// finos sobre a amostra.
class DigitalizadorDocumento {
  static Uint8List? digitalizar(Uint8List jpegBytes) {
    final imagem = img.decodeImage(jpegBytes);
    if (imagem == null) return null;

    var resultado = img.grayscale(imagem);
    resultado = img.adjustColor(resultado, contrast: 1.6, brightness: 1.05);

    return Uint8List.fromList(img.encodeJpg(resultado, quality: 90));
  }
}
