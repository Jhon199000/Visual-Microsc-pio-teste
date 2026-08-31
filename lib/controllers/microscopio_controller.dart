import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/uvc_camera_service.dart';
import 'package:flutter_ffi_uvc/flutter_ffi_uvc.dart';

class MicroscopioController extends ChangeNotifier {
  final UvcCameraService _service = UvcCameraService();

  UvcStatus _status = UvcStatus.disconnected;
  String? _lastError;
  StreamSubscription<UvcStatus>? _statusSub;

  UvcStatus get status => _status;
  bool get estaConectado => _status == UvcStatus.connected;
  bool get estaCarregando => _status == UvcStatus.connecting;
  int? get textureId => _service.isConnected ? _service.textureId : null;
  double? get currentAspectRatio => _service.aspectRatio;
  String? get lastError => _lastError;

  MicroscopioController() {
    _statusSub = _service.statusStream.listen((s) {
      _status = s;
      notifyListeners();
    });
  }

  Future<List<UvcUsbDevice>> listarDispositivos() => _service.listarDispositivos();

  Future<void> inicializar({int? deviceId}) async {
    _lastError = null;
    notifyListeners();

    final ok = await _service.connect(deviceId: deviceId);
    if (!ok) {
      _lastError = 'Não foi possível conectar ao microscópio';
      notifyListeners();
    }
  }

  Future<void> reconectar({int? deviceId}) async {
    await _service.disconnect();
    await inicializar(deviceId: deviceId);
  }

  /// Ejeta o dispositivo USB: apenas desconecta e libera o microscópio,
  /// sem tentar reconectar sozinho (diferente de reconectar()).
  Future<void> ejetar() async {
    await _service.disconnect();
  }

  UvcStillPicture? capturarFoto({int quality = 92}) {
    return _service.takePicture(quality: quality);
  }

  UvcPreviewFrame? capturarFrame() {
    return _service.captureFrame();
  }

  void girarHorario() {
    _service.rotateClockwise();
    notifyListeners();
  }

  void girarAntiHorario() {
    _service.rotateCounterClockwise();
    notifyListeners();
  }

  void espelharHorizontal() {
    _service.toggleFlipHorizontal();
    notifyListeners();
  }

  void espelharVertical() {
    _service.toggleFlipVertical();
    notifyListeners();
  }

  bool get estaGravando => _service.isRecording;

  int iniciarGravacao(String path) {
    final resultado = _service.startVideoRecording(path);
    notifyListeners();
    return resultado;
  }

  int pararGravacao() {
    final resultado = _service.stopVideoRecording();
    notifyListeners();
    return resultado;
  }

  List<UvcCameraControl> controlesDisponiveis() => _service.supportedControls();

  List<UvcCameraMode> modosDisponiveis() => _service.supportedModes();

  UvcCameraMode? get modoAtual => _service.currentMode;

  Future<bool> selecionarModo(UvcCameraMode modo) async {
    final ok = await _service.mudarModo(modo);
    notifyListeners();
    return ok;
  }

  int? lerControle(UvcControlId id) => _service.getControl(id);

  bool definirControle(UvcControlId id, int valor) => _service.setControl(id, valor);

  @override
  void dispose() {
    _statusSub?.cancel();
    _service.dispose();
    super.dispose();
  }
}
