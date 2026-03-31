// lib/widgets/disciplinas_section_widget.dart
import 'package:flutter/material.dart';
import '../modelos/disciplina.dart';

class DisciplinasSectionWidget extends StatelessWidget {
  final List<Disciplina> disciplinas;
  final bool isLoading;
  final VoidCallback? onViewAll;
  final Function(Disciplina)? onDisciplinaTap;

  const DisciplinasSectionWidget({
    super.key,
    required this.disciplinas,
    this.isLoading = false,
    this.onViewAll,
    this.onDisciplinaTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildContent(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(
                Icons.category,
                color: Colors.orange,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Disciplinas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (onViewAll != null && disciplinas.isNotEmpty)
            TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
              ),
              child: const Text(
                'Ver todas',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (disciplinas.isEmpty) {
      return _buildEmptyState();
    }

    return _buildDisciplinaList();
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 80,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(
              Icons.category_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'Nenhuma disciplina cadastrada',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisciplinaList() {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: disciplinas.length,
        itemBuilder: (context, index) {
          final disciplina = disciplinas[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: DisciplinaItem(
              disciplina: disciplina,
              onTap: () => onDisciplinaTap?.call(disciplina),
            ),
          );
        },
      ),
    );
  }
}

class DisciplinaItem extends StatelessWidget {
  final Disciplina disciplina;
  final VoidCallback? onTap;

  const DisciplinaItem({
    super.key,
    required this.disciplina,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          color: _getDisciplinaColor(disciplina.nome).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getDisciplinaColor(disciplina.nome).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: _getDisciplinaColor(disciplina.nome),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForDisciplina(disciplina.nome),
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              disciplina.nome,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _getDisciplinaColor(disciplina.nome),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _getDisciplinaColor(String nome) {
    switch (nome.toLowerCase()) {
      case 'matemática':
        return Colors.blue;
      case 'português':
        return Colors.green;
      case 'física':
        return Colors.orange;
      case 'química':
        return Colors.purple;
      case 'história':
        return Colors.red;
      case 'biologia':
        return Colors.teal;
      case 'inglês':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconForDisciplina(String nome) {
    switch (nome.toLowerCase()) {
      case 'matemática':
        return Icons.calculate;
      case 'português':
        return Icons.book;
      case 'física':
        return Icons.science;
      case 'química':
        return Icons.abc_sharp;
      case 'história':
        return Icons.history;
      case 'biologia':
        return Icons.biotech;
      case 'inglês':
        return Icons.translate;
      default:
        return Icons.category;
    }
  }
}