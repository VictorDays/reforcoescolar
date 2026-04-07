
import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../modelos/professor.dart';
import '../modelos/disciplina.dart';
import '../widgets/professor_card.dart';
import '../widgets/professor_form.dart';
import '../widgets/custom_dialog.dart';

class CrudProfessoresScreen extends StatefulWidget {
  const CrudProfessoresScreen({super.key});

  @override
  State<CrudProfessoresScreen> createState() => _CrudProfessoresScreenState();
}

class _CrudProfessoresScreenState extends State<CrudProfessoresScreen> {
  List<Professor> _professores = [];
  List<Disciplina> _disciplinas = [];
  bool _isLoading = true;
  String? _filtroDisciplina;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);
    final professores = await DBHelper.getAllProfessores(apenasAtivos: false);
    final disciplinas = await DBHelper.getAllDisciplinas();
    setState(() {
      _professores = professores;
      _disciplinas = disciplinas;
      _isLoading = false;
    });
  }

  Future<void> _adicionarProfessor() async {
    final result = await showDialog<Professor>(
      context: context,
      builder: (_) => ProfessorForm(disciplinas: _disciplinas),
    );

    if (result != null) {
      try {
        await DBHelper.insertProfessor(result);
        _carregarDados();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Professor adicionado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao adicionar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editarProfessor(Professor professor) async {
    final result = await showDialog<Professor>(
      context: context,
      builder: (_) => ProfessorForm(
        professor: professor,
        disciplinas: _disciplinas,
      ),
    );

    if (result != null) {
      try {
        await DBHelper.updateProfessor(result);
        _carregarDados();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Professor atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao atualizar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _excluirProfessor(Professor professor) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => CustomDialog(
        title: 'Excluir Professor',
        message: 'Tem certeza que deseja excluir "${professor.nome}"?',
        isConfirm: true,
      ),
    );

    if (confirm == true) {
      try {
        await DBHelper.deleteProfessor(professor.id!);
        _carregarDados();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Professor excluído com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _alternarAtivo(Professor professor) async {
    try {
      await DBHelper.toggleProfessorAtivo(professor.id!, !professor.ativo);
      _carregarDados();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao alterar status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Professor> _getProfessoresFiltrados() {
    if (_filtroDisciplina == null || _filtroDisciplina == 'Todas') {
      return _professores;
    }
    return _professores.where((p) => p.disciplina == _filtroDisciplina).toList();
  }

  @override
  Widget build(BuildContext context) {
    final professoresFiltrados = _getProfessoresFiltrados();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Professores'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _adicionarProfessor,
            icon: const Icon(Icons.add),
            tooltip: 'Adicionar Professor',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_disciplinas.isNotEmpty) _buildFiltroChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : professoresFiltrados.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: professoresFiltrados.length,
                        itemBuilder: (context, index) {
                          return ProfessorCard(
                            professor: professoresFiltrados[index],
                            onTap: () => _editarProfessor(professoresFiltrados[index]),
                            onDelete: () => _excluirProfessor(professoresFiltrados[index]),
                            onToggleAtivo: () => _alternarAtivo(professoresFiltrados[index]),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltroChips() {
    final disciplinasUnicas = ['Todas', ..._disciplinas.map((d) => d.nome).toList()];
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: disciplinasUnicas.length,
        itemBuilder: (context, index) {
          final disciplina = disciplinasUnicas[index];
          final isSelected = _filtroDisciplina == disciplina ||
              (_filtroDisciplina == null && disciplina == 'Todas');
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(disciplina),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _filtroDisciplina = disciplina == 'Todas' ? null : disciplina;
                });
              },
              backgroundColor: Colors.grey.shade100,
              selectedColor: Colors.green.shade100,
              labelStyle: TextStyle(
                color: isSelected ? Colors.green : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum professor cadastrado',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _adicionarProfessor,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Professor'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}