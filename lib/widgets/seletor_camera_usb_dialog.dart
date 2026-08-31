import 'package:flutter/material.dart';
import 'package:flutter_ffi_uvc/flutter_ffi_uvc.dart';
import '../controllers/microscopio_controller.dart';

/// Mostra um diálogo para o usuário escolher qual câmera USB usar, quando
/// mais de um dispositivo UVC está conectado. Tem botões "Atualizar"
/// (relista os dispositivos), "Cancelar" e "OK".
///
/// Retorna o `deviceId` escolhido, ou `null` se o usuário cancelou.
Future<String?> mostrarSeletorCameraUsb(
  BuildContext context,
  MicroscopioController controller,
  List<UvcDevice> dispositivosIniciais,
) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _SeletorCameraUsbDialog(
      controller: controller,
      dispositivosIniciais: dispositivosIniciais,
    ),
  );
}

class _SeletorCameraUsbDialog extends StatefulWidget {
  final MicroscopioController controller;
  final List<UvcDevice> dispositivosIniciais;

  const _SeletorCameraUsbDialog({
    required this.controller,
    required this.dispositivosIniciais,
  });

  @override
  State<_SeletorCameraUsbDialog> createState() => _SeletorCameraUsbDialogState();
}

class _SeletorCameraUsbDialogState extends State<_SeletorCameraUsbDialog> {
  late List<UvcDevice> _dispositivos;
  String? _selecionado;
  bool _atualizando = false;

  @override
  void initState() {
    super.initState();
    _dispositivos = widget.dispositivosIniciais;
    if (_dispositivos.isNotEmpty) {
      _selecionado = _dispositivos.first.deviceId;
    }
  }

  Future<void> _atualizar() async {
    setState(() => _atualizando = true);
    final lista = await widget.controller.listarDispositivos();
    if (!mounted) return;
    setState(() {
      _dispositivos = lista;
      _atualizando = false;
      if (_selecionado == null || !lista.any((d) => d.deviceId == _selecionado)) {
        _selecionado = lista.isNotEmpty ? lista.first.deviceId : null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Escolha a câmera USB'),
      content: SizedBox(
        width: double.maxFinite,
        child: _atualizando
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            : _dispositivos.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Nenhum dispositivo USB encontrado.'),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _dispositivos.map((dispositivo) {
                      return RadioListTile<String>(
                        title: Text(dispositivo.displayName),
                        value: dispositivo.deviceId,
                        groupValue: _selecionado,
                        onChanged: (v) => setState(() => _selecionado = v),
                      );
                    }).toList(),
                  ),
      ),
      actions: [
        TextButton(
          onPressed: _atualizando ? null : _atualizar,
          child: const Text('Atualizar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _selecionado == null
              ? null
              : () => Navigator.of(context).pop(_selecionado),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
