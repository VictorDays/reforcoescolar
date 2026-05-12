import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reforcoescolar/main.dart';
import '../controllers/auth_controller.dart';
import '../controllers/aluno_controller.dart';
import '../controllers/professor_controller.dart';
import '../models/usuario.dart';
import 'home_screen.dart';
import 'cadastro_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => AlunoController()),
        ChangeNotifierProvider(create: (_) => ProfessorController()),
      ],
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Consumer<AuthController>(
            builder: (context, authController, child) {
              if (authController.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.school,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Reforço Escolar',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 50),
                  
                  // Mensagem de erro
                  if (authController.erro != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        authController.erro!,
                        style: TextStyle(color: Colors.red.shade900),
                      ),
                    ),
                  
                  // Campo Email
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  
                  // Campo Senha
                  TextField(
                    controller: _senhaController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword 
                            ? Icons.visibility_off 
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Botão Entrar
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final success = await authController.login(
                          _emailController.text.trim(),
                          _senhaController.text,
                        );
                        
                        if (success && mounted) {
                          // Carregar dados adicionais baseado no tipo
                          final usuario = authController.usuarioLogado;
                          if (usuario != null) {
                            if (usuario.tipo == TipoUsuario.aluno) {
                              final alunoController = context.read<AlunoController>();
                              await alunoController.carregarPerfilAluno(usuario.id);
                            } else if (usuario.tipo == TipoUsuario.professor) {
                              final professorController = context.read<ProfessorController>();
                              await professorController.carregarPerfilProfessor(usuario.id);
                            }
                          }
                          
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MainScreen(usuario: usuario!),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Entrar',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Link para cadastro
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CadastroScreen(),
                        ),
                      );
                    },
                    child: const Text('Não tem conta? Cadastre-se'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}