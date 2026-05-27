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

  List<BottomNavigationBarItem> _getItems() {
    if (usuario.isAdmin) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Início'),
        BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings_rounded), label: 'Admin'),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Perfil'),
      ];
    } else if (usuario.isProfessor) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Início'),
        BottomNavigationBarItem(icon: Icon(Icons.inbox_rounded), label: 'Solicitações'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Agenda'),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Perfil'),
      ];
    } else {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Início'),
        BottomNavigationBarItem(icon: Icon(Icons.explore_rounded), label: 'Explorar'),
        BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'Minhas Aulas'),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Perfil'),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _getItems();
    final safeIndex = currentIndex < items.length ? currentIndex : 0;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: safeIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF5C6BC0),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        backgroundColor: Colors.white,
        elevation: 0,
        items: items,
      ),
    );
  }
}
