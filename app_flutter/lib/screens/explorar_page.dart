import 'package:flutter/material.dart';

import '../models/item.dart';
import '../utils/categorias.dart';
import '../widgets/estados.dart';
import '../widgets/item_card.dart';
import 'item_detail_screen.dart';

/// Aba "Explorar": busca, filtros por categoria/situação e grade de objetos.
class ExplorarPage extends StatefulWidget {
  final List<Item> itens;
  final bool carregando;
  final String? erro;
  final Future<void> Function() onRecarregar;

  const ExplorarPage({
    super.key,
    required this.itens,
    required this.carregando,
    required this.erro,
    required this.onRecarregar,
  });

  @override
  State<ExplorarPage> createState() => _ExplorarPageState();
}

class _ExplorarPageState extends State<ExplorarPage> {
  final _busca = TextEditingController();
  String _cat = ''; // '' = todas
  String _status = ''; // '' = em aberto

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  /// Itens que passam no filtro de situação (antes de categoria e busca).
  List<Item> get _baseStatus => widget.itens
      .where((i) => _status.isEmpty ? i.status != 'devolvido' : i.status == _status)
      .toList();

  List<Item> _filtrar() {
    final q = _busca.text.trim().toLowerCase();
    final lista = _baseStatus.where((i) {
      if (_cat.isNotEmpty && i.categoria != _cat) return false;
      if (q.isEmpty) return true;
      final texto =
          '${i.nome} ${i.descricao} ${i.local} ${categoriaDe(i.categoria).rotulo}'
              .toLowerCase();
      return texto.contains(q);
    }).toList();
    lista.sort((a, b) => b.data.compareTo(a.data));
    return lista;
  }

  void _abrir(Item item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
    );
  }

  Widget _stat(String numero, String rotulo) {
    return Padding(
      padding: const EdgeInsets.only(right: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(numero,
              style: const TextStyle(
                  color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
          Text(rotulo,
              style: const TextStyle(color: Color(0xFF9FABC9), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _hero() {
    int n(String s) => widget.itens.where((i) => i.status == s).length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16213A), Color(0xFF2B3158)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Perdeu algo? '),
                TextSpan(
                    text: 'Vamos achar.',
                    style: TextStyle(color: Color(0xFFFF8A6B))),
              ],
            ),
            style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                height: 1.1),
          ),
          const SizedBox(height: 8),
          const Text(
            'Veja o que foi encontrado e peça a devolução em poucos toques.',
            style: TextStyle(color: Color(0xFFB9C3DC), fontSize: 15),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _busca,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(color: Color(0xFF1D1A16)),
            decoration: InputDecoration(
              hintText: 'Buscar: mochila, chaves, fone…',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _stat('${n('achado')}', 'achados'),
              _stat('${n('perdido')}', 'procurados'),
              _stat('${n('devolvido')}', 'devolvidos'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chips() {
    final base = _baseStatus;
    int contagem(String slug) => base.where((i) => i.categoria == slug).length;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categorias.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final slug = i == 0 ? '' : categorias[i - 1].slug;
          final rotulo = i == 0
              ? '✨ Tudo (${base.length})'
              : '${categorias[i - 1].emoji} ${categorias[i - 1].rotulo} (${contagem(slug)})';
          return ChoiceChip(
            label: Text(rotulo),
            selected: _cat == slug,
            onSelected: (_) => setState(() => _cat = slug),
          );
        },
      ),
    );
  }

  Widget _situacao() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SegmentedButton<String>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(value: '', label: Text('Em aberto')),
          ButtonSegment(value: 'achado', label: Text('Achados')),
          ButtonSegment(value: 'perdido', label: Text('Procurados')),
          ButtonSegment(value: 'devolvido', label: Text('Devolvidos')),
        ],
        selected: {_status},
        onSelectionChanged: (s) => setState(() => _status = s.first),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lista = _filtrar();
    final semDados = widget.itens.isEmpty;

    return RefreshIndicator(
      onRefresh: widget.onRecarregar,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _hero()),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(child: _chips()),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverToBoxAdapter(child: _situacao()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Text(
                lista.length == 1 ? '1 objeto' : '${lista.length} objetos',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          ),
          if (widget.carregando && semDados)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          else if (widget.erro != null && semDados)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: ErroBox(
                  mensagem: widget.erro!,
                  onTentar: widget.onRecarregar,
                ),
              ),
            )
          else if (lista.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: VazioBox(
                  emoji: '🕵️',
                  titulo: 'Nada por aqui',
                  texto: 'Tente outra busca ou registre o que você perdeu.',
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 280,
                  mainAxisExtent: 292,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) =>
                      ItemCard(item: lista[i], onTap: () => _abrir(lista[i])),
                  childCount: lista.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
