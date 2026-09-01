import 'package:flutter/material.dart';

class _Gesto {
  final IconData icone;
  final String titulo;
  final String descricao;
  const _Gesto(this.icone, this.titulo, this.descricao);
}

const _gestos = [
  _Gesto(Icons.pinch, 'Pinça para zoom', 'Use dois dedos para aproximar ou afastar a imagem da câmera.'),
  _Gesto(Icons.touch_app, 'Toque duplo', 'Toque duas vezes na imagem para redefinir o zoom ao tamanho original.'),
  _Gesto(Icons.swipe, 'Arrastar', 'Com a imagem ampliada, arraste um dedo para navegar pela área capturada.'),
  _Gesto(Icons.touch_app_outlined, 'Toque simples (modo medição)', 'Toque em dois pontos da imagem para marcar a distância entre eles.'),
  _Gesto(Icons.visibility_off_outlined, 'Toque na tela', 'Toque em qualquer área vazia da imagem para esconder ou mostrar as barras de botões.'),
];

/// Tela simples explicando os gestos suportados na tela da câmera.
class GuiaGestosScreen extends StatelessWidget {
  const GuiaGestosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guia de gestos')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _gestos.length,
        separatorBuilder: (_, __) => const Divider(height: 24),
        itemBuilder: (context, index) {
          final gesto = _gestos[index];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(gesto.icone, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(gesto.titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(gesto.descricao, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
