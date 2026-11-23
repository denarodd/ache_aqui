import 'package:flutter/material.dart';

import '../models/item.dart';
import '../services/api_service.dart';
import '../services/preferencias.dart';

String? _obrigatorio(String? v) =>
    (v == null || v.trim().isEmpty) ? 'Preencha este campo' : null;

/// Formulário (bottom sheet) para pedir a devolução de um objeto.
/// Fecha com `true` quando o pedido é enviado.
class SolicitacaoSheet extends StatefulWidget {
  final Item item;

  const SolicitacaoSheet({super.key, required this.item});

  @override
  State<SolicitacaoSheet> createState() => _SolicitacaoSheetState();
}

class _SolicitacaoSheetState extends State<SolicitacaoSheet> {
  final _form = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _contato = TextEditingController();
  final _mensagem = TextEditingController();
  bool _enviando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    final p = await Preferencias.perfil();
    if (!mounted) return;
    _nome.text = p['nome'] ?? '';
    _contato.text = p['contato'] ?? '';
  }

  @override
  void dispose() {
    _nome.dispose();
    _contato.dispose();
    _mensagem.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _enviando = true;
      _erro = null;
    });
    try {
      final d = await ApiService.instance.criarDevolucao({
        'item_id': widget.item.id,
        'solicitante': _nome.text.trim(),
        'contato': _contato.text.trim(),
        'mensagem': _mensagem.text.trim(),
      });
      await Preferencias.addMinha(d.id);
      await Preferencias.salvarPerfil(_nome.text.trim(), _contato.text.trim());
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _enviando = false;
        _erro = e.mensagem;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final achado = widget.item.status == 'achado';
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(achado ? 'Pedir devolução' : 'Eu achei isso',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(widget.item.nome),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nome,
                maxLength: 120,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                    labelText: 'Seu nome', border: OutlineInputBorder()),
                validator: _obrigatorio,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contato,
                maxLength: 200,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: 'E-mail ou telefone', border: OutlineInputBorder()),
                validator: _obrigatorio,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _mensagem,
                maxLength: 1000,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: achado
                      ? 'Como comprovar que é seu?'
                      : 'Onde e como você encontrou?',
                  hintText: achado
                      ? 'Marcas, conteúdo, detalhes que só o dono sabe…'
                      : 'Descreva onde está o objeto agora…',
                  border: const OutlineInputBorder(),
                ),
                validator: _obrigatorio,
              ),
              if (_erro != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_erro!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _enviando ? null : _enviar,
                  style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: Text(_enviando ? 'Enviando…' : 'Enviar pedido'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
