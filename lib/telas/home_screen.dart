import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/usuario.dart';
import '../controllers/aluno_controller.dart';
import '../controllers/solicitacao_controller.dart';
import '../widgets/bottom_nav_bar.dart';
import 'dashboard_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin/admin_perfil_screen.dart';
import 'aluno/explorar_screen.dart';
import 'aluno/minhas_aulas_screen.dart';
import 'aluno/aluno_perfil_screen.dart';
import 'professor/solicitacoes_screen.dart';
import 'professor/agenda_screen.dart';
import 'professor/professor_perfil_screen.dart';

class HomeScreen extends StatefulWidget {
  final Usuario usuario;
  final int initialIndex;

  const HomeScreen({
    super.key,
    required this.usuario,
    this.initialIndex = 0,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _buildScreens();
  }

  void _buildScreens() {
    final u = widget.usuario;

    if (u.isAdmin) {
      _screens = [
        DashboardScreen(usuario: u),
        const AdminDashboardScreen(),
        AdminPerfilScreen(usuario: u),
      ];
    } else if (u.isProfessor) {
      _screens = [
        DashboardScreen(usuario: u),
        SolicitacoesScreen(usuario: u),
        AgendaScreen(usuario: u),
        ProfessorPerfilScreen(usuario: u),
      ];
    } else {
      // aluno
      _screens = [
        DashboardScreen(usuario: u),
        ExplorarScreen(usuario: u),
        MinhasAulasScreen(usuario: u),
        AlunoPerfilScreen(usuario: u),
      ];
    }

    if (_currentIndex >= _screens.length) _currentIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        usuario: widget.usuario,
        onTap: (index) {
          if (index < _screens.length) {
            setState(() => _currentIndex = index);
            if (index == 2 && widget.usuario.isAluno) {
              final alunoId =
                  context.read<AlunoController>().alunoAtual?['id'];
              if (alunoId != null) {
                context.read<SolicitacaoController>().carregarDoAluno(alunoId);
              }
            }
          }
        },
      ),
    );
  }
}
