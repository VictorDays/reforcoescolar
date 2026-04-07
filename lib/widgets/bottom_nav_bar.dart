import 'package:flutter/material.dart';
import '../modelos/usuario.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Usuario usuario;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.usuario,
  });

  @override
  Widget build(BuildContext context) {
    // Itens que todos os usuários veem
    final itensComuns = [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
      const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explorar'),
      const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
    ];

    // Item de Anunciar (CRUDs) - apenas para admin
    final itemAnunciar = const BottomNavigationBarItem(
      icon: Icon(Icons.add_circle), 
      label: 'Anunciar',
    );

    // Define os itens baseado no tipo de usuário
    final items = usuario.tipo == TipoUsuario.admin 
        ? [...itensComuns, itemAnunciar]  : itensComuns;                     

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: items,
    );
  }
}