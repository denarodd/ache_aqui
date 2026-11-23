import 'package:flutter/material.dart';

/// Categorias aceitas pela API (o `slug` é o valor enviado/recebido).
class Categoria {
  final String slug;
  final String rotulo;
  final String emoji;
  final Color cor;

  const Categoria(this.slug, this.rotulo, this.emoji, this.cor);
}

const List<Categoria> categorias = [
  Categoria('documentos', 'Documentos', '🪪', Color(0xFF7C8CFF)),
  Categoria('eletronicos', 'Eletrônicos', '🎧', Color(0xFF2FB8C9)),
  Categoria('roupas', 'Roupas', '🧥', Color(0xFFFF8A5C)),
  Categoria('acessorios', 'Acessórios', '👓', Color(0xFFC06CF0)),
  Categoria('chaves', 'Chaves', '🔑', Color(0xFFF2B632)),
  Categoria('bolsas_mochilas', 'Bolsas e mochilas', '🎒', Color(0xFF4FBF7A)),
  Categoria('outros', 'Outros', '📦', Color(0xFF8D98AD)),
];

Categoria categoriaDe(String slug) =>
    categorias.firstWhere((c) => c.slug == slug, orElse: () => categorias.last);
