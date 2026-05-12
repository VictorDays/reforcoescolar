import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../models/usuario.dart';
import 'login_screen.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  
  TipoUsuario _tipoSelecionado = TipoUsuario.aluno;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Consumer<AuthController>(
          builder: (context, authController, child) {
            if (authController.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.person_add,
                    size: 60,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 24),
                  
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
                  
                  // Campo Nome
                  TextField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome completo',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
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
                      labelText: 'Senha (mínimo 6 caracteres)',
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
                  const SizedBox(height: 16),
                  
                  // Campo Confirmar Senha
                  TextField(
                    controller: _confirmarSenhaController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirmar senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirmPassword 
                            ? Icons.visibility_off 
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Tipo de usuário
                  const Text(
                    'Você é:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<TipoUsuario>(
                          title: const Text('Aluno'),
                          value: TipoUsuario.aluno,
                          groupValue: _tipoSelecionado,
                          onChanged: (value) {
                            setState(() {
                              _tipoSelecionado = value!;
                            });
                          },
                          activeColor: Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<TipoUsuario>(
                          title: const Text('Professor'),
                          value: TipoUsuario.professor,
                          groupValue: _tipoSelecionado,
                          onChanged: (value) {
                            setState(() {
                              _tipoSelecionado = value!;
                            });
                          },
                          activeColor: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Botão Cadastrar
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Validar campos
                        if (_nomeController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Informe seu nome')),
                          );
                          return;
                        }
                        
                        if (_emailController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Informe seu email')),
                          );
                          return;
                        }
                        
                        if (_senhaController.text.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('A senha deve ter no mínimo 6 caracteres')),
                          );
                          return;
                        }
                        
                        if (_senhaController.text != _confirmarSenhaController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('As senhas não conferem')),
                          );
                          return;
                        }
                        
                        final success = await authController.cadastrar(
                          email: _emailController.text.trim(),
                          senha: _senhaController.text,
                          nome: _nomeController.text.trim(),
                          tipo: _tipoSelecionado,
                        );
                        
                        if (success && mounted) {
                          // Navegar para tela de complemento de cadastro
                          if (_tipoSelecionado == TipoUsuario.aluno) {
                            // Aqui pode redirecionar para tela de complemento de aluno
                            // Por enquanto vai direto para o login
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cadastro realizado! Faça login.')),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          } else {
                            // Professor - tela de complemento
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cadastro realizado! Faça login.')),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          }
                        }
                      },
                      child: const Text(
                        'Cadastrar',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Link para voltar ao login
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Já tenho conta? Fazer login'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}