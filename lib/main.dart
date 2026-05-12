import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:provider/provider.dart';
import 'config/supabase_config.dart';
import 'views/login_screen.dart';
import 'views/home_screen.dart';
import 'views/favoritos_screen.dart';
import 'views/explorar_screen.dart';
import 'views/anunciar_screen.dart';
import 'models/usuario.dart';
import 'widgets/bottom_nav_bar.dart';
import 'controllers/auth_controller.dart';
import 'controllers/aluno_controller.dart';
import 'controllers/professor_controller.dart';
import 'controllers/agendamento_controller.dart';
import 'controllers/disciplina_controller.dart';

void main() async {
  // Inicializar WidgetsFlutterBinding PRIMEIRO
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configuração para desktop (Windows/Linux)
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  // Inicializar Supabase
  await SupabaseConfig.initialize(
    url: 'https://cmgyxcaiifiqysvlqums.supabase.co',
    anonKey: 'sb_publishable_oZZi15FFGxxFpd9CxF2pjA_jqSiJ1ej',
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Controllers globais
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => AlunoController()),
        ChangeNotifierProvider(create: (_) => ProfessorController()),
        ChangeNotifierProvider(create: (_) => AgendamentoController()),
        ChangeNotifierProvider(create: (_) => DisciplinaController()),
      ],
      child: MaterialApp(
        title: 'Reforço Escolar',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
          // ✅ CORRIGIDO
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
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
      ),
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
      ExplorarScreen(usuario: widget.usuario),                   
      FavoritosScreen(usuario: widget.usuario), 
    ];

    // Tela de Anunciar (CRUDs) - apenas para admin
    const telaAnunciar = AnunciarScreen();

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