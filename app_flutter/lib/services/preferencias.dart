import 'package:shared_preferences/shared_preferences.dart';

/// Guarda no aparelho: pedidos feitos por este usuário e o último nome/contato.
class Preferencias {
  static const _kMinhas = 'minhas_solicitacoes';
  static const _kNome = 'nome';
  static const _kContato = 'contato';

  static Future<List<int>> minhas() async {
    final p = await SharedPreferences.getInstance();
    return (p.getStringList(_kMinhas) ?? []).map(int.parse).toList();
  }

  static Future<void> addMinha(int id) async {
    final p = await SharedPreferences.getInstance();
    final l = p.getStringList(_kMinhas) ?? [];
    l.add(id.toString());
    await p.setStringList(_kMinhas, l);
  }

  static Future<Map<String, String>> perfil() async {
    final p = await SharedPreferences.getInstance();
    return {
      'nome': p.getString(_kNome) ?? '',
      'contato': p.getString(_kContato) ?? '',
    };
  }

  static Future<void> salvarPerfil(String nome, String contato) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kNome, nome);
    await p.setString(_kContato, contato);
  }
}
