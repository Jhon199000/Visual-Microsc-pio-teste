import 'dart:async';
import 'package:flutter/material.dart';
import 'tela_principal.dart';
import 'onboarding_screen.dart';

/// Tela de entrada do app, inspirada no layout de referência:
/// cartão de status, relógio, atalhos verticais à direita, imagem de
/// destaque, botão "Primeiros passos" e três blaquinhos de destaque
/// (Amplie / Explore / Descubra) na base.
class TelaBoasVindas extends StatefulWidget {
  const TelaBoasVindas({super.key});

  @override
  State<TelaBoasVindas> createState() => _TelaBoasVindasState();
}

class _TelaBoasVindasState extends State<TelaBoasVindas> {
  late DateTime _agora;
  Timer? _relogio;

  static const _weekdays = [
    'dom.',
    'seg.',
    'ter.',
    'qua.',
    'qui.',
    'sex.',
    'sáb.',
  ];
  static const _months = [
    'jan.',
    'fev.',
    'mar.',
    'abr.',
    'mai.',
    'jun.',
    'jul.',
    'ago.',
    'set.',
    'out.',
    'nov.',
    'dez.',
  ];

  @override
  void initState() {
    super.initState();
    _agora = DateTime.now();
    _relogio = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _agora = DateTime.now());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) mostrarOnboardingSePrimeiraVez(context);
    });
  }

  @override
  void dispose() {
    _relogio?.cancel();
    super.dispose();
  }

  String get _horaFormatada {
    final h = _agora.hour.toString().padLeft(2, '0');
    final m = _agora.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get _dataFormatada {
    final dia = _weekdays[_agora.weekday % 7];
    final mes = _months[_agora.month - 1];
    return '$dia ${_agora.day}. $mes';
  }

  void _entrarNoApp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const TelaPrincipal()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF04070F),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fundo em degradê escuro, no tom azul do mockup
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF060B18),
                  Color(0xFF0B1530),
                  Color(0xFF071022),
                ],
              ),
            ),
          ),
          // Glow decorativo
          Positioned(
            top: -80,
            right: -60,
            child: _glow(const Color(0xFF7B2FF7), 220),
          ),
          Positioned(
            bottom: -60,
            left: -80,
            child: _glow(const Color(0xFF00D4FF), 260),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Topo: status + relógio + atalhos
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _cartaoStatus()),
                          const SizedBox(width: 12),
                          _relogioWidget(),
                          const SizedBox(width: 12),
                          _atalhosVerticais(),
                        ],
                      ),
                      const SizedBox(height: 28),
                      // Imagem de destaque (hero) com botão central de play
                      Expanded(
                        child: Center(
                          child: _cardHero(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Botão "Primeiros passos"
                      _botaoPrimeirosPassos(),
                      const SizedBox(height: 24),
                      // Rodapé com destaques
                      _rodapeDestaques(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(Color cor, double tamanho) {
    return IgnorePointer(
      child: Container(
        width: tamanho,
        height: tamanho,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [cor.withValues(alpha: 0.35), cor.withValues(alpha: 0.0)],
          ),
        ),
      ),
    );
  }

  Widget _cartaoStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF7B2FF7).withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF34D399)),
          ),
          const SizedBox(width: 10),
          const Flexible(
            child: Text(
              'Câmera USB detectada com sucesso',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.check_circle, color: Color(0xFF34D399), size: 18),
        ],
      ),
    );
  }

  Widget _relogioWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _horaFormatada,
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
        ),
        Text(
          _dataFormatada,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _atalhosVerticais() {
    return Column(
      children: [
        _atalho(
          icone: Icons.usb,
          cor: const Color(0xFF7B2FF7),
          label: 'USB',
          onTap: _entrarNoApp,
        ),
        const SizedBox(height: 10),
        _atalho(
          icone: Icons.settings,
          cor: const Color(0xFF2F80FF),
          label: 'Config.',
          onTap: () {
            _entrarNoApp();
          },
        ),
        const SizedBox(height: 10),
        _atalho(
          icone: Icons.photo_library,
          cor: const Color(0xFF12C6A0),
          label: 'Galeria',
          onTap: _entrarNoApp,
        ),
      ],
    );
  }

  Widget _atalho({
    required IconData icone,
    required Color cor,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cor.withValues(alpha: 0.15),
              border: Border.all(color: cor, width: 1.4),
            ),
            child: Icon(icone, color: cor, size: 18),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _cardHero() {
    return GestureDetector(
      onTap: _entrarNoApp,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.passthrough,
          children: [
            Image.asset(
              'assets/images/microscopio_hero.png',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botaoPrimeirosPassos() {
    return Center(
      child: GestureDetector(
        onTap: _entrarNoApp,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            gradient: const LinearGradient(
              colors: [Color(0xFF7B2FF7), Color(0xFF2F80FF), Color(0xFF00D4FF)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2F80FF).withValues(alpha: 0.45),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text(
                'Primeiros passos',
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rodapeDestaques() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _destaque(Icons.search, const Color(0xFF9B5CFF), 'Amplie.', 'Veja o invisível.'),
        _destaque(Icons.center_focus_strong, const Color(0xFF2F9BFF), 'Explore.', 'Cada detalhe importa.'),
        _destaque(Icons.eco, const Color(0xFF14D9A6), 'Descubra.', 'Um novo mundo.'),
      ],
    );
  }

  Widget _destaque(IconData icone, Color cor, String titulo, String subtitulo) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cor.withValues(alpha: 0.15),
              border: Border.all(color: cor, width: 1.2),
            ),
            child: Icon(icone, color: cor, size: 16),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titulo,
                  style: TextStyle(color: cor, fontSize: 12, fontWeight: FontWeight.w700),
                ),
                Text(
                  subtitulo,
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
