// lib/screens/crud_disciplinas_screen.dart
import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../modelos/disciplina.dart';
import '../widgets/disciplina_card.dart';
import '../widgets/disciplina_form.dart';
import '../widgets/custom_dialog.dart';

class CrudDisciplinasScreen extends StatefulWidget {
  const CrudDisciplinasScreen({super.key});

  @override
  State<CrudDisciplinasScreen> createState() => _CrudDisciplinasScreenState();
}

class _CrudDisciplinasScreenState extends State<CrudDisciplinasScreen> {
  List<Disciplina> _disciplinas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDisciplinas();
  }

  Future<void> _carregarDisciplinas() async {
    setState(() => _isLoading = true);
    final disciplinas = await DBHelper.getAllDisciplinas();
    setState(() {
      _disciplinas = disciplinas;
      _isLoading = false;
    });
  }

  Future<void> _adicionarDisciplina() async {
    final result = await showDialog<Disciplina>(
      context: context,
      builder: (_) => const DisciplinaForm(),
    );

    if (result != null) {
      try {
        await DBHelper.insertDisciplina(result);
        _carregarDisciplinas();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Disciplina adicionada com sucesso!'),
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

  Future<void> _editarDisciplina(Disciplina disciplina) async {
    final result = await showDialog<Disciplina>(
      context: context,
      builder: (_) => DisciplinaForm(disciplina: disciplina),
    );

    if (result != null) {
      try {
        await DBHelper.updateDisciplina(result);
        _carregarDisciplinas();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Disciplina atualizada com sucesso!'),
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

  Future<void> _excluirDisciplina(Disciplina disciplina) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => CustomDialog(
        title: 'Excluir Disciplina',
        message: 'Tem certeza que deseja excluir "${disciplina.nome}"?',
        isConfirm: true,
      ),
    );

    if (confirm == true) {
      try {
        await DBHelper.deleteDisciplina(disciplina.id!);
        _carregarDisciplinas();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Disciplina excluída com sucesso!'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Disciplinas'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _adicionarDisciplina,
            icon: const Icon(Icons.add),
            tooltip: 'Adicionar Disciplina',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _disciplinas.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _disciplinas.length,
                  itemBuilder: (context, index) {
                    return DisciplinaCard(
                      disciplina: _disciplinas[index],
                      onTap: () => _editarDisciplina(_disciplinas[index]),
                      onDelete: () => _excluirDisciplina(_disciplinas[index]),
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
            Icons.category_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma disciplina cadastrada',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _adicionarDisciplina,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Disciplina'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}