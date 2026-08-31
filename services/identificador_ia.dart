import 'dart:io';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class IdentificadorIA {
  final ImageLabeler _labeler = ImageLabeler(
    options: ImageLabelerOptions(confidenceThreshold: 0.4),
  );

  Future<List<ImageLabel>> identificar(File imagem) async {
    final inputImage = InputImage.fromFilePath(imagem.path);
    return _labeler.processImage(inputImage);
  }

  void dispose() {
    _labeler.close();
  }
}
