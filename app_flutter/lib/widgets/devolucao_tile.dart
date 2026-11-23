import 'package:flutter/material.dart';

import '../models/devolucao.dart';
import '../utils/formatadores.dart';
import 'status_badge.dart';

/// Cartão de um pedido de devolução. No painel da equipe mostra quem pediu
/// e os botões de aprovar/recusar.
class DevolucaoTile extends StatelessWidget {
  final Devolucao devolucao;
  final String emoji;
  final bool painel;
  final VoidCallback? onAprovar;
  final VoidCallback? onRecusar;

  const DevolucaoTile({
    super.key,
    required this.devolucao,
    this.emoji = '📦',
    this.painel = false,
    this.onAprovar,
    this.onRecusar,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final d = devolucao;
    final nome = d.itemNome.isEmpty ? 'Objeto #${d.itemId}' : d.itemNome;

    return Card(
      elevation: 0,
      color: cs.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StatusBadge(d.status),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$emoji $nome',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
                Text(tempoRelativo(d.data),
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
              ],
            ),
            if (painel) ...[
              const SizedBox(height: 8),
              Text('👤 ${d.solicitante} · ${d.contato}',
                  style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
            ],
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0x14808080),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(d.mensagem, style: const TextStyle(fontSize: 14)),
            ),
            if (painel && d.status == 'pendente') ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: onAprovar,
                    icon: const Icon(Icons.check),
                    label: const Text('Aprovar e marcar devolvido'),
                  ),
                  OutlinedButton(
                    onPressed: onRecusar,
                    child: const Text('Recusar'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
