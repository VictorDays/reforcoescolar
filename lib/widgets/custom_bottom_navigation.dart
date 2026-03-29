import 'package:flutter/material.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int indiceAtual;
  final Function(int) aoMudarAba;

  const CustomBottomNavigation({
    super.key,
    required this.indiceAtual,
    required this.aoMudarAba,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: indiceAtual,
      onTap: aoMudarAba,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explorar'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
        BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Anunciar'),
      ],
    );
  }
}