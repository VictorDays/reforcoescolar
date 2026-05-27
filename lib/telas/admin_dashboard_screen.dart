import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/admin_controller.dart';
import '../controllers/novidade_controller.dart';
import 'admin/admin_usuarios_screen.dart';
import 'admin/admin_professores_screen.dart';
import 'admin/admin_alunos_screen.dart';
import 'admin/admin_disciplinas_screen.dart';
import 'admin/admin_novidades_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  final List<_TabInfo> _tabs = [
    _TabInfo('Usuários', Icons.people_rounded, const AdminUsuariosScreen()),
    _TabInfo('Professores', Icons.school_rounded, const AdminProfessoresScreen()),
    _TabInfo('Alunos', Icons.person_rounded, const AdminAlunosScreen()),
    _TabInfo('Disciplinas', Icons.book_rounded, const AdminDisciplinasScreen()),
    _TabInfo('Novidades', Icons.campaign_rounded, const AdminNovidades()),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().carregarUsuarios();
      context.read<AdminController>().carregarProfessores();
      context.read<AdminController>().carregarAlunos();
      context.read<AdminController>().carregarDisciplinas();
      context.read<NovidadeController>().carregarTodas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings_rounded, size: 22),
            const SizedBox(width: 8),
            Text(_tabs[_selectedIndex].label,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          if (_selectedIndex == 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildResumoIndicator(),
            ),
        ],
      ),
      body: _tabs[_selectedIndex].widget,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF5C6BC0),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          items: _tabs
              .map((t) => BottomNavigationBarItem(
                    icon: Icon(t.icon),
                    label: t.label,
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildResumoIndicator() {
    return Consumer<AdminController>(
      builder: (ctx, ctrl, _) {
        final total = ctrl.usuarios.length;
        if (total == 0) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.people_rounded, size: 16, color: Colors.white),
              const SizedBox(width: 4),
              Text('$total', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }
}

class _TabInfo {
  final String label;
  final IconData icon;
  final Widget widget;
  const _TabInfo(this.label, this.icon, this.widget);
}
