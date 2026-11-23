import 'package:flutter/material.dart';

import '../models/item.dart';
import '../utils/categorias.dart';
import '../utils/formatadores.dart';
import 'status_badge.dart';

/// Faixa colorida da categoria (com a foto por cima, se existir).
class ItemVisual extends StatelessWidget {
  final Item item;
  final double altura;
  final double tamanhoEmoji;

  const ItemVisual({
    super.key,
    required this.item,
    this.altura = 130,
    this.tamanhoEmoji = 52,
  });

  @override
  Widget build(BuildContext context) {
    final cat = categoriaDe(item.categoria);
    return Container(
      height: altura,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cat.cor, Color.lerp(cat.cor, Colors.white, 0.45)!],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(child: Text(cat.emoji, style: TextStyle(fontSize: tamanhoEmoji))),
          if (item.foto.isNotEmpty)
            Image.network(
              item.foto,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          Positioned(top: 10, left: 10, child: StatusBadge(item.status)),
        ],
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;

  const ItemCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pequeno = TextStyle(fontSize: 12, color: cs.onSurfaceVariant);

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ItemVisual(item: item),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nome,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700, height: 1.2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.descricao.isEmpty ? 'Sem descrição.' : item.descricao,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                    ),
                    const Spacer(),
                    Text('📍 ${item.local}',
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: pequeno),
                    Text('🕒 ${tempoRelativo(item.data)}', style: pequeno),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
