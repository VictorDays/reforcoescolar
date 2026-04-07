// lib/screens/explorar_screen.dart
import 'package:flutter/material.dart';
import 'package:reforcoescolar/telas/login_screen.dart';
import '../database/db_helper.dart';
import '../modelos/professor.dart';
import '../modelos/usuario.dart';
import '../widgets/professor_card.dart';
import '../main.dart';

class ExplorarScreen extends StatefulWidget {
  final Usuario usuario;

  const ExplorarScreen({super.key, required this.usuario});

  @override
  State<ExplorarScreen> createState() => _ExplorarScreenState();
}

class _ExplorarScreenState extends State<ExplorarScreen> {
  List<Professor> _professores = [];
  List<String> _disciplinas = ['Todas'];
  Set<int> _favoritos = {};
  bool _isLoading = true;
  String _filtroDisciplina = 'Todas';

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);
    
    final professores = await DBHelper.getAllProfessores();
    final disciplinasDB = await DBHelper.getAllDisciplinas();
    
    if (widget.usuario.tipo == TipoUsuario.aluno) {
      final favoritosList = await DBHelper.getFavoritosByUsuario(widget.usuario.id!);
      setState(() {
        _favoritos = favoritosList.map((p) => p.id!).toSet();
      });
    }
    
    setState(() {
      _professores = professores;
      _disciplinas = ['Todas', ...disciplinasDB.map((d) => d.nome)];
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorito(Professor professor) async {
    if (widget.usuario.tipo != TipoUsuario.aluno) return;
    
    final isFav = _favoritos.contains(professor.id);
    
    if (isFav) {
      await DBHelper.removeFavorito(widget.usuario.id!, professor.id!);
      setState(() => _favoritos.remove(professor.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${professor.nome} removido dos favoritos'), backgroundColor: Colors.orange),
      );
    } else {
      await DBHelper.addFavorito(widget.usuario.id!, professor.id!);
      setState(() => _favoritos.add(professor.id!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${professor.nome} adicionado aos favoritos'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _logout() async {
    await DBHelper.logout(widget.usuario.id!);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  List<Professor> get _professoresFiltrados {
    if (_filtroDisciplina == 'Todas') return _professores;
    return _professores.where((p) => p.disciplina == _filtroDisciplina).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar Professores'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Botão de logout para todos os usuários
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _disciplinas.map((disciplina) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(disciplina),
                      selected: _filtroDisciplina == disciplina,
                      onSelected: (_) => setState(() => _filtroDisciplina = disciplina),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _professoresFiltrados.isEmpty
                    ? const Center(child: Text('Nenhum professor encontrado'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _professoresFiltrados.length,
                        itemBuilder: (context, index) {
                          final professor = _professoresFiltrados[index];
                          final isFavorito = _favoritos.contains(professor.id);
                          return ProfessorCard(
                            professor: professor,
                            isFavorito: isFavorito,
                            onFavoritoTap: widget.usuario.tipo == TipoUsuario.aluno
                                ? () => _toggleFavorito(professor)
                                : null,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}