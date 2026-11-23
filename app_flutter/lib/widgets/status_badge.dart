import 'package:flutter/material.dart';

class _Estilo {
  final Color fundo;
  final Color cor;
  final String texto;
  const _Estilo(this.fundo, this.cor, this.texto);
}

_Estilo _estilo(String status) {
  switch (status) {
    case 'achado':
      return const _Estilo(Color(0xFFDFF5E8), Color(0xFF14804A), 'ACHADO');
    case 'perdido':
      return const _Estilo(Color(0xFFFDE5E1), Color(0xFFC2331F), 'PERDIDO');
    case 'pendente':
      return const _Estilo(Color(0xFFFFF0D6), Color(0xFFA85D00), 'PENDENTE');
    case 'aprovada':
      return const _Estilo(Color(0xFFDFF5E8), Color(0xFF14804A), 'APROVADA');
    case 'recusada':
      return const _Estilo(Color(0xFFFDE5E1), Color(0xFFC2331F), 'RECUSADA');
    case 'devolvido':
      return const _Estilo(Color(0xFFECE5DA), Color(0xFF6F675D), 'DEVOLVIDO');
    default:
      return _Estilo(const Color(0xFFECE5DA), const Color(0xFF6F675D),
          status.toUpperCase());
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final e = _estilo(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: e.fundo,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        e.texto,
        style: TextStyle(
          color: e.cor,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
