import 'package:flutter/material.dart';
import '../widgets/custom_bottom_navigation.dart';
import 'home_screen.dart';
import 'anunciar_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _indice = 0;
  final List<Widget> _telas = [
    const HomeScreen(),
    const Center(child: Text("Explorar")),
    const Center(child: Text("Favoritos")),
    const AnunciarScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _indice, children: _telas),
      bottomNavigationBar: CustomBottomNavigation(
        indiceAtual: _indice,
        aoMudarAba: (i) => setState(() => _indice = i),
      ),
    );
  }
}