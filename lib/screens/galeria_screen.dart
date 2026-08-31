import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class GaleriaScreen extends StatelessWidget {
  final List<File> fotos;

  const GaleriaScreen({super.key, required this.fotos});

  Future<void> _compartilhar(File arquivo) async {
    await SharePlus.instance.share(ShareParams(files: [XFile(arquivo.path)]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Fotos salvas (${fotos.length})'),
      ),
      body: fotos.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma foto capturada ainda',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: fotos.length,
              itemBuilder: (context, index) {
                final foto = fotos[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _FotoDetalheScreen(
                        arquivo: foto,
                        onCompartilhar: () => _compartilhar(foto),
                      ),
                    ),
                  ),
                  child: Image.file(foto, fit: BoxFit.cover),
                );
              },
            ),
    );
  }
}

class _FotoDetalheScreen extends StatelessWidget {
  final File arquivo;
  final VoidCallback onCompartilhar;

  const _FotoDetalheScreen({required this.arquivo, required this.onCompartilhar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: onCompartilhar,
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1.0,
          maxScale: 5.0,
          child: Image.file(arquivo),
        ),
      ),
    );
  }
}
