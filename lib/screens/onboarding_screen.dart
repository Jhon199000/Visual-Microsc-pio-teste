import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _PassoOnboarding {
  final IconData icone;
  final List<Color> gradiente;
  final String titulo;
  final String descricao;

  const _PassoOnboarding({
    required this.icone,
    required this.gradiente,
    required this.titulo,
    required this.descricao,
  });
}

const _passos = [
  _PassoOnboarding(
    icone: Icons.usb,
    gradiente: [Color(0xFF7B2FF7), Color(0xFF2F80FF)],
    titulo: 'Conecte o microscópio',
    descricao:
        'Ligue seu microscópio USB ao celular usando um cabo OTG. Assim que for detectado, a imagem aparece automaticamente na tela.',
  ),
  _PassoOnboarding(
    icone: Icons.center_focus_strong,
    gradiente: [Color(0xFF2F80FF), Color(0xFF00D4FF)],
    titulo: 'Ajuste e explore',
    descricao:
        'Use dois dedos para dar zoom, gire a imagem e ajuste brilho, cor e foco pelos botões laterais.',
  ),
  _PassoOnboarding(
    icone: Icons.photo_camera_outlined,
    gradiente: [Color(0xFF14D9A6), Color(0xFF2F9BFF)],
    titulo: 'Capture e organize',
    descricao:
        'Tire fotos, grave vídeos e faça medições. Tudo fica salvo na galeria do app para você rever depois.',
  ),
];

/// Mostra o onboarding em tela cheia apenas na primeira vez que o app é
/// aberto (controlado por uma flag em SharedPreferences). Chame a partir de
/// uma tela já montada, por exemplo no primeiro frame da tela de boas-vindas.
Future<void> mostrarOnboardingSePrimeiraVez(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final jaViu = prefs.getBool('onboarding_visto') ?? false;
  if (jaViu || !context.mounted) return;
  await Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const OnboardingScreen(), fullscreenDialog: true),
  );
}

/// Tela de onboarding "Como começar", com 3 passos ilustrados.
/// Pode ser aberta manualmente (ex.: a partir de Configurações) para o
/// usuário rever a introdução quando quiser.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _paginaAtual = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _concluir() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_visto', true);
    if (mounted) Navigator.of(context).pop();
  }

  void _proximo() {
    if (_paginaAtual == _passos.length - 1) {
      _concluir();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ultimaPagina = _paginaAtual == _passos.length - 1;
    return Scaffold(
      backgroundColor: const Color(0xFF04070F),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8, top: 4),
                child: TextButton(
                  onPressed: _concluir,
                  child: const Text('Pular', style: TextStyle(color: Colors.white70)),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _passos.length,
                onPageChanged: (i) => setState(() => _paginaAtual = i),
                itemBuilder: (context, index) => _paginaPasso(_passos[index], index + 1),
              ),
            ),
            _indicadorPaginas(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _proximo,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF2F80FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    ultimaPagina ? 'Começar' : 'Próximo',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paginaPasso(_PassoOnboarding passo, int numero) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: passo.gradiente),
              boxShadow: [
                BoxShadow(
                  color: passo.gradiente.last.withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(passo.icone, color: Colors.white, size: 64),
          ),
          const SizedBox(height: 12),
          Text(
            'Passo $numero de ${_passos.length}',
            style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Text(
            passo.titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            passo.descricao,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _indicadorPaginas() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_passos.length, (index) {
        final ativo = index == _paginaAtual;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: ativo ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: ativo ? const Color(0xFF2F80FF) : Colors.white24,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
