import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/categorias.dart';
import '../utils/formatadores.dart';

String? _obrigatorio(String? v) =>
    (v == null || v.trim().isEmpty) ? 'Preencha este campo' : null;

/// Tela para registrar um objeto achado ou perdido. Fecha com `true` ao publicar.
class NovoItemScreen extends StatefulWidget {
  const NovoItemScreen({super.key});

  @override
  State<NovoItemScreen> createState() => _NovoItemScreenState();
}

class _NovoItemScreenState extends State<NovoItemScreen> {
  final _form = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _descricao = TextEditingController();
  final _local = TextEditingController();
  final _foto = TextEditingController();
  final _contato = TextEditingController();

  String _tipo = 'achado';
  String _cat = 'outros';
  DateTime _dataHora = DateTime.now();
  bool _enviando = false;
  String? _erro;

  @override
  void dispose() {
    _nome.dispose();
    _descricao.dispose();
    _local.dispose();
    _foto.dispose();
    _contato.dispose();
    super.dispose();
  }

  Future<void> _escolherDataHora() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dataHora,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dataHora),
    );
    if (t == null || !mounted) return;
    setState(() => _dataHora = DateTime(d.year, d.month, d.day, t.hour, t.minute));
  }

  Future<void> _publicar() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _enviando = true;
      _erro = null;
    });
    try {
      await ApiService.instance.criarItem({
        'nome': _nome.text.trim(),
        'categoria': _cat,
        'status': _tipo,
        'descricao': _descricao.text.trim(),
        'local': _local.text.trim(),
        'data': isoComFuso(_dataHora),
        'foto': _foto.text.trim(),
        'contato': _contato.text.trim(),
      });
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
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar objeto')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'achado', label: Text('🙌 Eu achei')),
                ButtonSegment(value: 'perdido', label: Text('😢 Eu perdi')),
              ],
              selected: {_tipo},
              onSelectionChanged: (s) => setState(() => _tipo = s.first),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _nome,
              maxLength: 80,
              decoration: const InputDecoration(
                  labelText: 'O que é?',
                  hintText: 'Ex.: Garrafa azul',
                  border: OutlineInputBorder()),
              validator: _obrigatorio,
            ),
            const SizedBox(height: 8),
            Text('Categoria',
                style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in categorias)
                  ChoiceChip(
                    label: Text('${c.emoji} ${c.rotulo}'),
                    selected: _cat == c.slug,
                    onSelected: (_) => setState(() => _cat = c.slug),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _descricao,
              maxLength: 1000,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Cor, marca, detalhes que ajudam a identificar',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _local,
              maxLength: 200,
              decoration: const InputDecoration(
                  labelText: 'Onde?',
                  hintText: 'Ex.: Biblioteca',
                  border: OutlineInputBorder()),
              validator: _obrigatorio,
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _escolherDataHora,
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Quando?',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.event),
                ),
                child: Text(dataHora(_dataHora)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _foto,
              maxLength: 500,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                  labelText: 'Link da foto (opcional)',
                  hintText: 'https://…',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _contato,
              maxLength: 200,
              decoration: const InputDecoration(
                  labelText: 'Seu contato (opcional)',
                  hintText: 'E-mail ou telefone',
                  border: OutlineInputBorder()),
            ),
            if (_erro != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_erro!, style: TextStyle(color: cs.error)),
              ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _enviando ? null : _publicar,
              style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              child: Text(_enviando ? 'Publicando…' : 'Publicar'),
            ),
          ],
        ),
      ),
    );
  }
}
