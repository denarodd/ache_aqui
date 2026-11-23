import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/devolucao.dart';
import '../models/item.dart';

class ApiException implements Exception {
  final String mensagem;
  ApiException(this.mensagem);

  @override
  String toString() => mensagem;
}

/// Cliente da API de Achados e Perdidos (server.py).
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  /// Endereço da API. Pode ser trocado pela engrenagem no topo do app.
  /// - Emulador Android enxerga o PC em 10.0.2.2
  /// - Chrome / Windows usam localhost
  String baseUrl = _padrao();

  static String _padrao() {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api';
    }
    return 'http://localhost:8080/api';
  }

  static const _json = {'Content-Type': 'application/json; charset=utf-8'};

  Future<dynamic> _enviar(String metodo, String caminho, {Object? corpo}) async {
    final uri = Uri.parse('$baseUrl$caminho');
    http.Response r;
    try {
      final Future<http.Response> req = switch (metodo) {
        'GET' => http.get(uri),
        'POST' => http.post(uri, headers: _json, body: jsonEncode(corpo)),
        _ => http.patch(uri, headers: _json, body: jsonEncode(corpo)),
      };
      r = await req.timeout(const Duration(seconds: 10));
    } catch (_) {
      throw ApiException(
          'Não consegui falar com a API ($baseUrl). Ela está rodando?');
    }

    dynamic dados;
    try {
      dados = jsonDecode(utf8.decode(r.bodyBytes));
    } catch (_) {
      dados = null;
    }

    if (r.statusCode >= 400) {
      final msg = (dados is Map && dados['erro'] != null)
          ? dados['erro'].toString()
          : 'Erro ${r.statusCode}';
      throw ApiException(msg);
    }
    return dados;
  }

  // ---------- itens ----------
  Future<List<Item>> listarItens() async {
    final j = await _enviar('GET', '/itens') as List;
    return j.map((e) => Item.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Item> criarItem(Map<String, dynamic> dados) async {
    final j = await _enviar('POST', '/itens', corpo: dados);
    return Item.fromJson(j as Map<String, dynamic>);
  }

  Future<void> atualizarItem(int id, String status) =>
      _enviar('PATCH', '/itens/$id', corpo: {'status': status});

  // ---------- devoluções ----------
  Future<List<Devolucao>> listarDevolucoes() async {
    final j = await _enviar('GET', '/devolucoes') as List;
    return j.map((e) => Devolucao.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Devolucao> criarDevolucao(Map<String, dynamic> dados) async {
    final j = await _enviar('POST', '/devolucoes', corpo: dados);
    return Devolucao.fromJson(j as Map<String, dynamic>);
  }

  Future<void> atualizarDevolucao(int id, String status) =>
      _enviar('PATCH', '/devolucoes/$id', corpo: {'status': status});
}
