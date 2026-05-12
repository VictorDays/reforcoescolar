import 'package:flutter/material.dart';
import '../models/usuario.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Usuario usuario;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.usuario,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Define os itens baseado no tipo de usuário
    final List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Início',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.explore),
        label: 'Explorar',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.favorite),
        label: 'Favoritos',
      ),
    ];

    // Adiciona item de admin se for admin
    if (usuario.tipo == TipoUsuario.admin) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
      );
    }

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: items,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
    );
  }
}