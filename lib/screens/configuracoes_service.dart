import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ações que podem ser atribuídas aos botões físicos de volume.
enum AcaoBotaoVolume { nenhuma, zoom, rotacao, brilho }

extension AcaoBotaoVolumeLabel on AcaoBotaoVolume {
  String get label {
    switch (this) {
      case AcaoBotaoVolume.nenhuma:
        return 'Nenhuma';
      case AcaoBotaoVolume.zoom:
        return 'Zoom';
      case AcaoBotaoVolume.rotacao:
        return 'Rotação';
      case AcaoBotaoVolume.brilho:
        return 'Brilho';
    }
  }
}

/// Serviço singleton que centraliza todas as configurações do app.
///
/// É um [ChangeNotifier] para que telas (como o MaterialApp, para o tema)
/// possam reagir a mudanças. Todos os valores são persistidos em
/// SharedPreferences e carregados uma única vez em [carregar].
class ConfiguracoesService extends ChangeNotifier {
  ConfiguracoesService._();
  static final ConfiguracoesService instancia = ConfiguracoesService._();

  static const _chaveTema = 'config_tema';
  static const _chaveIdioma = 'config_idioma';
  static const _chavePngSemPerda = 'config_png_sem_perda';
  static const _chaveVideoComSom = 'config_video_com_som';
  static const _chaveReducaoCintilacao = 'config_reducao_cintilacao';
  static const _chaveManterConectadoFundo = 'config_manter_conectado_fundo';
  static const _chaveBotaoVolumeCima = 'config_botao_volume_cima';
  static const _chaveBotaoVolumeBaixo = 'config_botao_volume_baixo';

  ThemeMode tema = ThemeMode.dark;
  String idioma = 'pt';
  bool pngSemPerda = false;
  bool videoComSom = true;
  int reducaoCintilacaoHz = 0; // 0 = desligado, 50 ou 60
  bool manterConectadoEmSegundoPlano = false;
  AcaoBotaoVolume botaoVolumeCima = AcaoBotaoVolume.nenhuma;
  AcaoBotaoVolume botaoVolumeBaixo = AcaoBotaoVolume.nenhuma;

  bool _carregado = false;
  bool get carregado => _carregado;

  Future<void> carregar() async {
    if (_carregado) return;
    final prefs = await SharedPreferences.getInstance();
    tema = ThemeMode.values[prefs.getInt(_chaveTema) ?? ThemeMode.dark.index];
    idioma = prefs.getString(_chaveIdioma) ?? 'pt';
    pngSemPerda = prefs.getBool(_chavePngSemPerda) ?? false;
    videoComSom = prefs.getBool(_chaveVideoComSom) ?? true;
    reducaoCintilacaoHz = prefs.getInt(_chaveReducaoCintilacao) ?? 0;
    manterConectadoEmSegundoPlano = prefs.getBool(_chaveManterConectadoFundo) ?? false;
    botaoVolumeCima = AcaoBotaoVolume.values[prefs.getInt(_chaveBotaoVolumeCima) ?? 0];
    botaoVolumeBaixo = AcaoBotaoVolume.values[prefs.getInt(_chaveBotaoVolumeBaixo) ?? 0];
    _carregado = true;
    notifyListeners();
  }

  Future<void> definirTema(ThemeMode novo) async {
    tema = novo;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_chaveTema, novo.index);
  }

  Future<void> definirIdioma(String novo) async {
    idioma = novo;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveIdioma, novo);
  }

  Future<void> definirPngSemPerda(bool valor) async {
    pngSemPerda = valor;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chavePngSemPerda, valor);
  }

  Future<void> definirVideoComSom(bool valor) async {
    videoComSom = valor;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chaveVideoComSom, valor);
  }

  Future<void> definirReducaoCintilacao(int hz) async {
    reducaoCintilacaoHz = hz;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_chaveReducaoCintilacao, hz);
  }

  Future<void> definirManterConectadoEmSegundoPlano(bool valor) async {
    manterConectadoEmSegundoPlano = valor;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chaveManterConectadoFundo, valor);
  }

  Future<void> definirBotaoVolumeCima(AcaoBotaoVolume acao) async {
    botaoVolumeCima = acao;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_chaveBotaoVolumeCima, acao.index);
  }

  Future<void> definirBotaoVolumeBaixo(AcaoBotaoVolume acao) async {
    botaoVolumeBaixo = acao;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_chaveBotaoVolumeBaixo, acao.index);
  }
}
