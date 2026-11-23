import 'package:flutter/material.dart';

import '../models/item.dart';
import '../utils/categorias.dart';
import '../utils/formatadores.dart';
import '../widgets/item_card.dart';
import 'solicitacao_sheet.dart';

/// Detalhes de um objeto + botão para pedir a devolução.
class ItemDetailScreen extends StatelessWidget {
  final Item item;

  const ItemDetailScreen({super.key, required this.item});

  Future<void> _pedir(BuildContext context) async {
    final enviou = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => SolicitacaoSheet(item: item),
    );
    if (enviou == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido enviado! Acompanhe na aba Pedidos ✅')),
      );
    }
  }

  Widget _fato(String emoji, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 30, child: Text(emoji, style: const TextStyle(fontSize: 18))),
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final achado = item.status == 'achado';
    final devolvido = item.status == 'devolvido';

    return Scaffold(
      appBar: AppBar(
        title: Text(item.nome, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          ItemVisual(item: item, altura: 240, tamanhoEmoji: 90),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.nome,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(categoriaDe(item.categoria).rotulo,
                    style: TextStyle(color: cs.onSurfaceVariant)),
                const SizedBox(height: 14),
                Text(
                  item.descricao.isEmpty ? 'Sem descrição.' : item.descricao,
                  style: const TextStyle(fontSize: 16, height: 1.4),
                ),
                const SizedBox(height: 18),
                _fato('📍', item.local),
                _fato('🕒', '${dataHora(item.data)} · ${tempoRelativo(item.data)}'),
                if (item.status == 'perdido' && item.contato.isNotEmpty)
                  _fato('📞', item.contato),
                const SizedBox(height: 14),
                if (devolvido)
                  const Text('Este objeto já foi devolvido ao dono. 🎉',
                      style: TextStyle(fontSize: 15))
                else
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _pedir(context),
                      icon: const Icon(Icons.back_hand_outlined),
                      label: Text(achado ? 'É meu! Pedir devolução' : 'Eu achei isso'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
