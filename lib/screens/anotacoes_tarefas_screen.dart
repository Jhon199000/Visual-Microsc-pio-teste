import 'package:flutter/material.dart';
import '../services/anotacoes_tarefas_service.dart';

class AnotacoesTarefasScreen extends StatefulWidget {
  const AnotacoesTarefasScreen({super.key});

  @override
  State<AnotacoesTarefasScreen> createState() => _AnotacoesTarefasScreenState();
}

class _AnotacoesTarefasScreenState extends State<AnotacoesTarefasScreen>
    with SingleTickerProviderStateMixin {
  final _service = AnotacoesTarefasService();
  late final TabController _tabController;

  List<Anotacao> _anotacoes = [];
  List<Tarefa> _tarefas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _carregarTudo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregarTudo() async {
    final anotacoes = await _service.listarAnotacoes();
    final tarefas = await _service.listarTarefas();
    if (!mounted) return;
    setState(() {
      _anotacoes = anotacoes;
      _tarefas = tarefas;
      _carregando = false;
    });
  }

  bool get _abaAnotacoes => _tabController.index == 0;

  Future<void> _criar() async {
    if (_abaAnotacoes) {
      await _abrirEditorAnotacao();
    } else {
      await _abrirCriadorTarefa();
    }
  }

  // ---------------- Anotações ----------------

  Future<void> _abrirEditorAnotacao({Anotacao? existente}) async {
    final tituloController = TextEditingController(text: existente?.titulo ?? '');
    final conteudoController = TextEditingController(text: existente?.conteudo ?? '');

    final salvar = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              existente == null ? 'Nova anotação' : 'Editar anotação',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: tituloController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: conteudoController,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(labelText: 'Anotação', alignLabelWithHint: true),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Salvar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (salvar != true) return;
    final titulo = tituloController.text.trim();
    final conteudo = conteudoController.text.trim();
    if (titulo.isEmpty && conteudo.isEmpty) return;

    if (existente != null) {
      existente.titulo = titulo.isEmpty ? 'Sem título' : titulo;
      existente.conteudo = conteudo;
    } else {
      _anotacoes.insert(
        0,
        Anotacao(
          id: _service.gerarId(),
          titulo: titulo.isEmpty ? 'Sem título' : titulo,
          conteudo: conteudo,
          criadaEm: DateTime.now(),
        ),
      );
    }
    setState(() {});
    await _service.salvarAnotacoes(_anotacoes);
  }

  Future<void> _excluirAnotacao(Anotacao anotacao) async {
    setState(() => _anotacoes.removeWhere((a) => a.id == anotacao.id));
    await _service.salvarAnotacoes(_anotacoes);
  }

  // ---------------- Tarefas ----------------

  Future<void> _abrirCriadorTarefa() async {
    final controller = TextEditingController();
    final titulo = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova tarefa'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'O que precisa ser feito?'),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
    final texto = titulo?.trim();
    if (texto == null || texto.isEmpty) return;
    setState(() {
      _tarefas.insert(
        0,
        Tarefa(id: _service.gerarId(), titulo: texto, criadaEm: DateTime.now()),
      );
    });
    await _service.salvarTarefas(_tarefas);
  }

  Future<void> _alternarConcluida(Tarefa tarefa, bool? valor) async {
    setState(() => tarefa.concluida = valor ?? false);
    await _service.salvarTarefas(_tarefas);
  }

  Future<void> _excluirTarefa(Tarefa tarefa) async {
    setState(() => _tarefas.removeWhere((t) => t.id == tarefa.id));
    await _service.salvarTarefas(_tarefas);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anotações & Tarefas'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => setState(() {}),
          tabs: const [
            Tab(text: 'Anotações', icon: Icon(Icons.sticky_note_2_outlined)),
            Tab(text: 'Tarefas', icon: Icon(Icons.checklist_outlined)),
          ],
        ),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_abaListaAnotacoes(), _abaListaTarefas()],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _criar,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _abaListaAnotacoes() {
    if (_anotacoes.isEmpty) {
      return _estadoVazio(
        icone: Icons.sticky_note_2_outlined,
        texto: 'Nenhuma anotação ainda.\nToque em + para criar a primeira.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _anotacoes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final anotacao = _anotacoes[index];
        return Dismissible(
          key: ValueKey(anotacao.id),
          direction: DismissDirection.endToStart,
          background: _fundoExcluir(),
          onDismissed: (_) => _excluirAnotacao(anotacao),
          child: Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              title: Text(anotacao.titulo, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                anotacao.conteudo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(_dataCurta(anotacao.criadaEm)),
              onTap: () => _abrirEditorAnotacao(existente: anotacao),
            ),
          ),
        );
      },
    );
  }

  Widget _abaListaTarefas() {
    if (_tarefas.isEmpty) {
      return _estadoVazio(
        icone: Icons.checklist_outlined,
        texto: 'Nenhuma tarefa ainda.\nToque em + para adicionar.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _tarefas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final tarefa = _tarefas[index];
        return Dismissible(
          key: ValueKey(tarefa.id),
          direction: DismissDirection.endToStart,
          background: _fundoExcluir(),
          onDismissed: (_) => _excluirTarefa(tarefa),
          child: CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            value: tarefa.concluida,
            onChanged: (v) => _alternarConcluida(tarefa, v),
            title: Text(
              tarefa.titulo,
              style: tarefa.concluida
                  ? const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)
                  : null,
            ),
          ),
        );
      },
    );
  }

  Widget _fundoExcluir() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
      child: const Icon(Icons.delete_outline, color: Colors.white),
    );
  }

  Widget _estadoVazio({required IconData icone, required String texto}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(texto, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  String _dataCurta(DateTime data) {
    final d = data.day.toString().padLeft(2, '0');
    final m = data.month.toString().padLeft(2, '0');
    return '$d/$m';
  }
}
