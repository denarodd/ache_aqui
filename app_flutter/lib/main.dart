import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/home_screen.dart';

void main() => runApp(const AcheAquiApp());

class AcheAquiApp extends StatelessWidget {
  const AcheAquiApp({super.key});

  static const _semente = Color(0xFFFF5A36);
  static const _fundo = Color(0xFFFAF6F0);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ache Aqui',
      debugShowCheckedModeBanner: false,
      // Português do Brasil (calendário, relógio, botões)
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _semente),
        scaffoldBackgroundColor: _fundo,
        appBarTheme: const AppBarTheme(
          backgroundColor: _fundo,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _semente,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
