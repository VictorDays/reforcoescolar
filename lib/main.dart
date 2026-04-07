// lib/main.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'telas/login_screen.dart';
import 'telas/home_screen.dart';
import 'telas/favoritos_screen.dart';
import 'telas/explorar_screen.dart';
import 'telas/anunciar_screen.dart';
import 'modelos/usuario.dart';
import 'widgets/bottom_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reforço Escolar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/home':
            final usuario = settings.arguments as Usuario;
            return MaterialPageRoute(builder: (_) => MainScreen(usuario: usuario));
          default:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
      },
    );
  }
}

// Tela principal com bottom navigation bar
class MainScreen extends StatefulWidget {
  final Usuario usuario;
  final int initialIndex;

  const MainScreen({
    super.key,
    required this.usuario,
    this.initialIndex = 0,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _buildScreens();
  }

  void _buildScreens() {
    // Telas que todos os usuários veem
    final telasComuns = [
      HomeScreen(usuario: widget.usuario),     
      ExplorarScreen(usuario: widget.usuario ),                   
      FavoritosScreen(usuario: widget.usuario), 
    ];

    // Tela de Anunciar (CRUDs) - apenas para admin
    final telaAnunciar = const AnunciarScreen();

    // Define as telas baseado no tipo de usuário
    _screens = widget.usuario.tipo == TipoUsuario.admin 
        ? [...telasComuns, telaAnunciar]  
        : telasComuns;                    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        usuario: widget.usuario,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}