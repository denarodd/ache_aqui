/// Objeto achado ou perdido (recurso /api/itens).
class Item {
  final int id;
  final String nome;
  final String descricao;
  final String categoria;
  final String status; // achado | perdido | devolvido
  final String local;
  final String foto;
  final String contato;
  final DateTime data;

  const Item({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.categoria,
    required this.status,
    required this.local,
    required this.foto,
    required this.contato,
    required this.data,
  });

  factory Item.fromJson(Map<String, dynamic> j) => Item(
        id: j['id'] as int,
        nome: (j['nome'] ?? '') as String,
        descricao: (j['descricao'] ?? '') as String,
        categoria: (j['categoria'] ?? 'outros') as String,
        status: (j['status'] ?? 'achado') as String,
        local: (j['local'] ?? '') as String,
        foto: (j['foto'] ?? '') as String,
        contato: (j['contato'] ?? '') as String,
        data: (DateTime.tryParse((j['data'] ?? '') as String) ?? DateTime.now())
            .toLocal(),
      );
}
