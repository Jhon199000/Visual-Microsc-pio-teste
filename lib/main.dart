import 'package:flutter/material.dart';
import 'screens/tela_boas_vindas.dart';
import 'services/configuracoes_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MicroscopioApp());
}

class MicroscopioApp extends StatefulWidget {
  const MicroscopioApp({super.key});

  @override
  State<MicroscopioApp> createState() => _MicroscopioAppState();
}

class _MicroscopioAppState extends State<MicroscopioApp> {
  final ConfiguracoesService _config = ConfiguracoesService.instancia;

  @override
  void initState() {
    super.initState();
    _config.addListener(_onConfigChanged);
    _config.carregar();
  }

  @override
  void dispose() {
    _config.removeListener(_onConfigChanged);
    super.dispose();
  }

  void _onConfigChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Microscópio USB',
      themeMode: _config.tema,
      theme: ThemeData(brightness: Brightness.light, useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const TelaBoasVindas(),
    );
  }
}
