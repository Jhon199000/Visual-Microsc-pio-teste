import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_ffi_uvc/flutter_ffi_uvc.dart';
import '../controllers/microscopio_controller.dart';
import '../services/configuracoes_service.dart';
import 'guia_gestos_screen.dart';
import 'onboarding_screen.dart';

/// Link da loja usado no botão "Avaliar o app".
/// TODO: trocar pelo link definitivo quando o app for publicado.
const _urlAvaliarApp = 'https://play.google.com/store/apps/details?id=com.microscopio.usb';
const _emailFeedback = 'feedback@microscopio-usb.app';

class ControlesScreen extends StatefulWidget {
  final MicroscopioController controller;

  const ControlesScreen({super.key, required this.controller});

  @override
  State<ControlesScreen> createState() => _ControlesScreenState();
}

class _ControlesScreenState extends State<ControlesScreen> {
  late List<UvcCameraControl> _controles;
  final Map<UvcControlId, int> _valores = {};
  final ConfiguracoesService _config = ConfiguracoesService.instancia;

  String _versaoApp = '';

  @override
  void initState() {
    super.initState();
    _controles = widget.controller.controlesDisponiveis();
    for (final controle in _controles) {
      final atual = widget.controller.lerControle(controle.id);
      if (atual != null) {
        _valores[controle.id] = atual;
      }
    }
    _config.addListener(_onConfigChanged);
    _carregarVersao();
  }

  @override
  void dispose() {
    _config.removeListener(_onConfigChanged);
    super.dispose();
  }

  void _onConfigChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _carregarVersao() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _versaoApp = '${info.version} (build ${info.buildNumber})');
      }
    } catch (_) {
      if (mounted) setState(() => _versaoApp = '—');
    }
  }

  void _alterar(UvcCameraControl controle, int novoValor) {
    final ok = widget.controller.definirControle(controle.id, novoValor);
    if (ok) {
      setState(() => _valores[controle.id] = novoValor);
    }
  }

  Future<void> _abrirLink(String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o link')),
      );
    }
  }

  Future<void> _enviarFeedback() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _emailFeedback,
      query: 'subject=${Uri.encodeComponent('Feedback - Microscópio USB')}',
    );
    final ok = await launchUrl(uri);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o app de e-mail')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _secao('Aparência'),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('Tema'),
            subtitle: Text(_labelTema(_config.tema)),
            onTap: _abrirSeletorTema,
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Idioma'),
            subtitle: Text(_labelIdioma(_config.idioma)),
            onTap: _abrirSeletorIdioma,
          ),
          const Divider(height: 32),
          _secao('Captura'),
          SwitchListTile(
            secondary: const Icon(Icons.image_outlined),
            title: const Text('Salvar foto em PNG sem perda'),
            subtitle: const Text('Além do JPEG, também usa PNG (arquivos maiores)'),
            value: _config.pngSemPerda,
            onChanged: (v) => _config.definirPngSemPerda(v),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.mic_none_outlined),
            title: const Text('Gravar vídeo com som'),
            value: _config.videoComSom,
            onChanged: (v) => _config.definirVideoComSom(v),
          ),
          ListTile(
            leading: const Icon(Icons.tungsten_outlined),
            title: const Text('Redução de cintilação'),
            subtitle: Text(_labelCintilacao(_config.reducaoCintilacaoHz)),
            onTap: _abrirSeletorCintilacao,
          ),
          const Divider(height: 32),
          _secao('Dispositivo'),
          SwitchListTile(
            secondary: const Icon(Icons.usb),
            title: const Text('Manter microscópio conectado em segundo plano'),
            subtitle: const Text('Evita desconectar a câmera ao minimizar o app'),
            value: _config.manterConectadoEmSegundoPlano,
            onChanged: (v) => _config.definirManterConectadoEmSegundoPlano(v),
          ),
          ListTile(
            leading: const Icon(Icons.volume_up_outlined),
            title: const Text('Botão de volume (+)'),
            subtitle: Text(_config.botaoVolumeCima.label),
            onTap: () => _abrirSeletorBotaoVolume(cima: true),
          ),
          ListTile(
            leading: const Icon(Icons.volume_down_outlined),
            title: const Text('Botão de volume (-)'),
            subtitle: Text(_config.botaoVolumeBaixo.label),
            onTap: () => _abrirSeletorBotaoVolume(cima: false),
          ),
          const Divider(height: 32),
          _secao('Ajuda e suporte'),
          ListTile(
            leading: const Icon(Icons.flag_outlined),
            title: const Text('Como começar'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const OnboardingScreen(), fullscreenDialog: true),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.gesture_outlined),
            title: const Text('Guia de gestos'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const GuiaGestosScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.star_border),
            title: const Text('Avaliar o app'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _abrirLink(_urlAvaliarApp),
          ),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('Enviar feedback'),
            onTap: _enviarFeedback,
          ),
          const Divider(height: 32),
          _secao('Controles da câmera'),
          if (_controles.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Esta câmera não expõe controles ajustáveis (brilho, contraste, etc.), ou o microscópio não está conectado.',
                textAlign: TextAlign.left,
              ),
            )
          else
            ..._controles.map((controle) {
              final valorAtual = _valores[controle.id] ?? controle.defaultValue;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(controle.label),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: valorAtual.toDouble().clamp(
                                  controle.min.toDouble(),
                                  controle.max.toDouble(),
                                ),
                            min: controle.min.toDouble(),
                            max: controle.max.toDouble(),
                            divisions: (controle.max - controle.min) > 0
                                ? (controle.max - controle.min)
                                : null,
                            onChanged: (v) => _alterar(controle, v.round()),
                          ),
                        ),
                        SizedBox(
                          width: 48,
                          child: Text('$valorAtual', textAlign: TextAlign.end),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Versão $_versaoApp',
              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _secao(String titulo) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        titulo,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.5),
      ),
    );
  }

  String _labelTema(ThemeMode modo) {
    switch (modo) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Escuro';
      case ThemeMode.system:
        return 'Automático (sistema)';
    }
  }

  String _labelIdioma(String codigo) {
    switch (codigo) {
      case 'pt':
        return 'Português';
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return codigo;
    }
  }

  String _labelCintilacao(int hz) {
    switch (hz) {
      case 50:
        return '50 Hz';
      case 60:
        return '60 Hz';
      default:
        return 'Desligada';
    }
  }

  Future<void> _abrirSeletorTema() async {
    final escolha = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((modo) {
            return RadioListTile<ThemeMode>(
              title: Text(_labelTema(modo)),
              value: modo,
              groupValue: _config.tema,
              onChanged: (v) => Navigator.pop(context, v),
            );
          }).toList(),
        ),
      ),
    );
    if (escolha != null) _config.definirTema(escolha);
  }

  Future<void> _abrirSeletorIdioma() async {
    const opcoes = ['pt', 'en', 'es'];
    final escolha = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: opcoes.map((codigo) {
            return RadioListTile<String>(
              title: Text(_labelIdioma(codigo)),
              value: codigo,
              groupValue: _config.idioma,
              onChanged: (v) => Navigator.pop(context, v),
            );
          }).toList(),
        ),
      ),
    );
    if (escolha != null) _config.definirIdioma(escolha);
  }

  Future<void> _abrirSeletorCintilacao() async {
    const opcoes = [0, 50, 60];
    final escolha = await showModalBottomSheet<int>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: opcoes.map((hz) {
            return RadioListTile<int>(
              title: Text(_labelCintilacao(hz)),
              value: hz,
              groupValue: _config.reducaoCintilacaoHz,
              onChanged: (v) => Navigator.pop(context, v),
            );
          }).toList(),
        ),
      ),
    );
    if (escolha != null) _config.definirReducaoCintilacao(escolha);
  }

  Future<void> _abrirSeletorBotaoVolume({required bool cima}) async {
    final atual = cima ? _config.botaoVolumeCima : _config.botaoVolumeBaixo;
    final escolha = await showModalBottomSheet<AcaoBotaoVolume>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: AcaoBotaoVolume.values.map((acao) {
            return RadioListTile<AcaoBotaoVolume>(
              title: Text(acao.label),
              value: acao,
              groupValue: atual,
              onChanged: (v) => Navigator.pop(context, v),
            );
          }).toList(),
        ),
      ),
    );
    if (escolha != null) {
      if (cima) {
        _config.definirBotaoVolumeCima(escolha);
      } else {
        _config.definirBotaoVolumeBaixo(escolha);
      }
    }
  }
}
