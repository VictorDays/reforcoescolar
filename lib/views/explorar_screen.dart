import 'package:flutter/material.dart';
import '../models/usuario.dart';

class ExplorarScreen extends StatelessWidget {
  final Usuario usuario;

  const ExplorarScreen({
    super.key,
    required this.usuario,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar Professores'),
      ),
      body: const Center(
        child: Text('Tela de Explorar - Em desenvolvimento'),
      ),
    );
  }
}