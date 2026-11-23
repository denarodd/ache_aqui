/// Pedido de devolução (recurso /api/devolucoes).
class Devolucao {
  final int id;
  final int itemId;
  final String itemNome;
  final String solicitante;
  final String contato;
  final String mensagem;
  final String status; // pendente | aprovada | recusada
  final DateTime data;

  const Devolucao({
    required this.id,
    required this.itemId,
    required this.itemNome,
    required this.solicitante,
    required this.contato,
    required this.mensagem,
    required this.status,
    required this.data,
  });

  factory Devolucao.fromJson(Map<String, dynamic> j) {
    final item = j['item'];
    return Devolucao(
      id: j['id'] as int,
      itemId: j['item_id'] as int,
      itemNome: item is Map ? ((item['nome'] ?? '') as String) : '',
      solicitante: (j['solicitante'] ?? '') as String,
      contato: (j['contato'] ?? '') as String,
      mensagem: (j['mensagem'] ?? '') as String,
      status: (j['status'] ?? 'pendente') as String,
      data: (DateTime.tryParse((j['data'] ?? '') as String) ?? DateTime.now())
          .toLocal(),
    );
  }
}
