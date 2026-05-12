import 'package:flutter/material.dart';
import '../models/usuario.dart';

class FavoritosScreen extends StatelessWidget {
  final Usuario usuario;

  const FavoritosScreen({
    super.key,
    required this.usuario,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Favoritos'),
      ),
      body: const Center(
        child: Text('Tela de Favoritos - Em desenvolvimento'),
      ),
    );
  }
}