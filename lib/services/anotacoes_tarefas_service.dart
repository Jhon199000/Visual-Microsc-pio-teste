import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Anotacao {
  final String id;
  String titulo;
  String conteudo;
  final DateTime criadaEm;

  Anotacao({
    required this.id,
    required this.titulo,
    required this.conteudo,
    required this.criadaEm,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'conteudo': conteudo,
        'criadaEm': criadaEm.toIso8601String(),
      };

  factory Anotacao.fromJson(Map<String, dynamic> json) => Anotacao(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        conteudo: json['conteudo'] as String,
        criadaEm: DateTime.parse(json['criadaEm'] as String),
      );
}

class Tarefa {
  final String id;
  String titulo;
  bool concluida;
  final DateTime criadaEm;

  Tarefa({
    required this.id,
    required this.titulo,
    this.concluida = false,
    required this.criadaEm,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'concluida': concluida,
        'criadaEm': criadaEm.toIso8601String(),
      };

  factory Tarefa.fromJson(Map<String, dynamic> json) => Tarefa(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        concluida: json['concluida'] as bool? ?? false,
        criadaEm: DateTime.parse(json['criadaEm'] as String),
      );
}

/// Serviço simples de persistência local (SharedPreferences, como o resto
/// do app) para anotações e tarefas ligadas às observações do microscópio.
class AnotacoesTarefasService {
  static const _chaveAnotacoes = 'anotacoes_lista';
  static const _chaveTarefas = 'tarefas_lista';

  Future<List<Anotacao>> listarAnotacoes() async {
    final prefs = await SharedPreferences.getInstance();
    final bruto = prefs.getStringList(_chaveAnotacoes) ?? [];
    final lista = bruto.map((s) => Anotacao.fromJson(jsonDecode(s))).toList();
    lista.sort((a, b) => b.criadaEm.compareTo(a.criadaEm));
    return lista;
  }

  Future<void> salvarAnotacoes(List<Anotacao> lista) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _chaveAnotacoes,
      lista.map((a) => jsonEncode(a.toJson())).toList(),
    );
  }

  Future<List<Tarefa>> listarTarefas() async {
    final prefs = await SharedPreferences.getInstance();
    final bruto = prefs.getStringList(_chaveTarefas) ?? [];
    final lista = bruto.map((s) => Tarefa.fromJson(jsonDecode(s))).toList();
    lista.sort((a, b) => b.criadaEm.compareTo(a.criadaEm));
    return lista;
  }

  Future<void> salvarTarefas(List<Tarefa> lista) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _chaveTarefas,
      lista.map((t) => jsonEncode(t.toJson())).toList(),
    );
  }

  String gerarId() => DateTime.now().microsecondsSinceEpoch.toString();
}
