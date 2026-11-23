import 'package:flutter/material.dart';

import '../models/devolucao.dart';
import '../models/item.dart';
import '../services/api_service.dart';
import '../services/preferencias.dart';
import '../utils/categorias.dart';
import '../widgets/devolucao_tile.dart';
import '../widgets/estados.dart';

String _emojiDe(List<Item> itens, int itemId) {
  for (final i in itens) {
    if (i.id == itemId) return categoriaDe(i.categoria).emoji;
  }
  return '📦';
}

Widget _titulo(String titulo, String sub) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(titulo, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
      const SizedBox(height: 2),
      Text(sub),
      const SizedBox(height: 14),
    ],
  );
}

// ===================== Aba "Pedidos" (do próprio usuário) =====================

class MinhasPage extends StatefulWidget {
  final bool ativa;
  final List<Item> itens;

  const MinhasPage({super.key, required this.ativa, required this.itens});

  @override
  State<MinhasPage> createState() => _MinhasPageState();
}

class _MinhasPageState extends State<MinhasPage> {
  List<Devolucao> _lista = [];
  bool _carregando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    if (widget.ativa) _carregar();
  }

  @override
  void didUpdateWidget(covariant MinhasPage antigo) {
    super.didUpdateWidget(antigo);
    if (!antigo.ativa && widget.ativa) _carregar(); // recarrega ao abrir a aba
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final ids = await Preferencias.minhas();
      final todas = await ApiService.instance.listarDevolucoes();
      if (!mounted) return;
      final minhas = todas.where((d) => ids.contains(d.id)).toList()
        ..sort((a, b) => b.id.compareTo(a.id));
      setState(() => _lista = minhas);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _erro = e.mensagem);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando && _lista.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          _titulo('Meus pedidos', 'Acompanhe as devoluções que você pediu neste aparelho.'),
          if (_erro != null)
            ErroBox(mensagem: _erro!, onTentar: _carregar)
          else if (_lista.isEmpty)
            const VazioBox(
              emoji: '📭',
              titulo: 'Nenhum pedido ainda',
              texto: 'Quando você pedir a devolução de um objeto, ele aparece aqui.',
            )
          else
            for (final d in _lista)
              DevolucaoTile(devolucao: d, emoji: _emojiDe(widget.itens, d.itemId)),
        ],
      ),
    );
  }
}

// ===================== Aba "Equipe" (aprovar / recusar) =====================

class PainelPage extends StatefulWidget {
  final bool ativa;
  final List<Item> itens;
  final VoidCallback onMudou; // avisa a tela inicial para recarregar os objetos

  const PainelPage({
    super.key,
    required this.ativa,
    required this.itens,
    required this.onMudou,
  });

  @override
  State<PainelPage> createState() => _PainelPageState();
}

class _PainelPageState extends State<PainelPage> {
  List<Devolucao> _todas = [];
  bool _carregando = false;
  String? _erro;
  String _filtro = 'pendente';

  @override
  void initState() {
    super.initState();
    if (widget.ativa) _carregar();
  }

  @override
  void didUpdateWidget(covariant PainelPage antigo) {
    super.didUpdateWidget(antigo);
    if (!antigo.ativa && widget.ativa) _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final l = await ApiService.instance.listarDevolucoes();
      if (!mounted) return;
      setState(() => _todas = l);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _erro = e.mensagem);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _decidir(Devolucao d, String status) async {
    final msg = ScaffoldMessenger.of(context);
    try {
      await ApiService.instance.atualizarDevolucao(d.id, status);
      if (status == 'aprovada') {
        await ApiService.instance.atualizarItem(d.itemId, 'devolvido');
      }
      widget.onMudou();
      await _carregar();
      msg.showSnackBar(SnackBar(
        content: Text(status == 'aprovada'
            ? 'Aprovado! Objeto marcado como devolvido ✅'
            : 'Pedido recusado'),
      ));
    } on ApiException catch (e) {
      msg.showSnackBar(SnackBar(content: Text(e.mensagem)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando && _todas.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    int n(String s) => _todas.where((d) => d.status == s).length;
    final lista = _todas.where((d) => d.status == _filtro).toList()
      ..sort((a, b) => b.id.compareTo(a.id));

    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          _titulo('Painel da equipe',
              'Analise os pedidos. Aprovar marca o objeto como devolvido.'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                    value: 'pendente', label: Text('Pendentes (${n('pendente')})')),
                ButtonSegment(
                    value: 'aprovada', label: Text('Aprovadas (${n('aprovada')})')),
                ButtonSegment(
                    value: 'recusada', label: Text('Recusadas (${n('recusada')})')),
              ],
              selected: {_filtro},
              onSelectionChanged: (s) => setState(() => _filtro = s.first),
            ),
          ),
          const SizedBox(height: 14),
          if (_erro != null)
            ErroBox(mensagem: _erro!, onTentar: _carregar)
          else if (lista.isEmpty)
            const VazioBox(
              emoji: '🎉',
              titulo: 'Nada por aqui',
              texto: 'Sem pedidos nesta lista.',
            )
          else
            for (final d in lista)
              DevolucaoTile(
                devolucao: d,
                emoji: _emojiDe(widget.itens, d.itemId),
                painel: true,
                onAprovar: () => _decidir(d, 'aprovada'),
                onRecusar: () => _decidir(d, 'recusada'),
              ),
        ],
      ),
    );
  }
}
