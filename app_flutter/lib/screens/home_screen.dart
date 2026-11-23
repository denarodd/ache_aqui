import 'package:flutter/material.dart';

import '../models/item.dart';
import '../services/api_service.dart';
import 'explorar_page.dart';
import 'novo_item_screen.dart';
import 'solicitacoes_pages.dart';

/// Tela principal: barra de navegação com Explorar, Pedidos e Equipe.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _aba = 0;
  List<Item> _itens = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final l = await ApiService.instance.listarItens();
      if (!mounted) return;
      setState(() => _itens = l);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _erro = e.mensagem);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _novo() async {
    final criou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const NovoItemScreen()),
    );
    if (criou == true && mounted) {
      _carregar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Objeto publicado! Obrigado por ajudar 🙌')),
      );
    }
  }

  Future<void> _configurarApi() async {
    final c = TextEditingController(text: ApiService.instance.baseUrl);
    final nova = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Endereço da API'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: c,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            const Text(
              'Chrome / Windows: http://localhost:8080/api\n'
              'Emulador Android: http://10.0.2.2:8080/api\n'
              'Celular real: http://IP-DO-PC:8080/api',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, c.text.trim()),
              child: const Text('Salvar')),
        ],
      ),
    );
    if (nova != null && nova.isNotEmpty) {
      ApiService.instance.baseUrl =
          nova.endsWith('/') ? nova.substring(0, nova.length - 1) : nova;
      _carregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🔎', style: TextStyle(fontSize: 22)),
            SizedBox(width: 8),
            Text('Ache Aqui', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Endereço da API',
            icon: const Icon(Icons.settings_outlined),
            onPressed: _configurarApi,
          ),
        ],
      ),
      body: IndexedStack(
        index: _aba,
        children: [
          ExplorarPage(
            itens: _itens,
            carregando: _carregando,
            erro: _erro,
            onRecarregar: _carregar,
          ),
          MinhasPage(ativa: _aba == 1, itens: _itens),
          PainelPage(
            ativa: _aba == 2,
            itens: _itens,
            onMudou: () {
              _carregar();
            },
          ),
        ],
      ),
      floatingActionButton: _aba == 0
          ? FloatingActionButton.extended(
              onPressed: _novo,
              icon: const Icon(Icons.add),
              label: const Text('Registrar'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _aba,
        onDestinationSelected: (i) => setState(() => _aba = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explorar',
          ),
          NavigationDestination(
            icon: Icon(Icons.mail_outline),
            selectedIcon: Icon(Icons.mail),
            label: 'Pedidos',
          ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings),
            label: 'Equipe',
          ),
        ],
      ),
    );
  }
}
