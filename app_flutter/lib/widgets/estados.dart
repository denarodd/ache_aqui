import 'package:flutter/material.dart';

/// Mensagem de erro com botão "Tentar de novo".
class ErroBox extends StatelessWidget {
  final String mensagem;
  final VoidCallback onTentar;

  const ErroBox({super.key, required this.mensagem, required this.onTentar});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔌', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          const Text('API fora do ar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(mensagem, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          FilledButton(onPressed: onTentar, child: const Text('Tentar de novo')),
          const SizedBox(height: 10),
          const Text(
            'Inicie a API com "python server.py" e confira o endereço na engrenagem ⚙️',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Lista vazia.
class VazioBox extends StatelessWidget {
  final String emoji;
  final String titulo;
  final String texto;

  const VazioBox({
    super.key,
    required this.emoji,
    required this.titulo,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 52)),
          const SizedBox(height: 8),
          Text(titulo,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(texto, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
