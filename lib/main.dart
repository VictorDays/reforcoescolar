import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/supabase_config.dart';
import 'controllers/auth_controller.dart';
import 'controllers/aluno_controller.dart';
import 'controllers/professor_controller.dart';
import 'controllers/admin_controller.dart';
import 'controllers/novidade_controller.dart';
import 'controllers/favorito_controller.dart';
import 'controllers/solicitacao_controller.dart';
import 'telas/login_screen.dart';
import 'telas/cadastro_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => AlunoController()),
        ChangeNotifierProvider(create: (_) => ProfessorController()),
        ChangeNotifierProvider(create: (_) => AdminController()),
        ChangeNotifierProvider(create: (_) => NovidadeController()),
        ChangeNotifierProvider(create: (_) => FavoritoController()),
        ChangeNotifierProvider(create: (_) => SolicitacaoController()),
      ],
      child: MaterialApp(
        title: 'Reforço Escolar',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF5C6BC0),
            primary: const Color(0xFF5C6BC0),
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: const Color(0xFFF5F6FA),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF5C6BC0),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        initialRoute: '/login',
        routes: {
          '/login': (_) => const LoginScreen(),
          '/cadastro': (_) => const CadastroScreen(),
        },
      ),
    );
  }
}
