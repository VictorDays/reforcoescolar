
import 'package:flutter/material.dart';
import '../modelos/disciplina.dart';

class DisciplinaCard extends StatelessWidget {
  final Disciplina disciplina;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const DisciplinaCard({
    super.key,
    required this.disciplina,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForDisciplina(disciplina.nome),
                  color: Colors.orange.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      disciplina.nome,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${disciplina.id != null ? 'ID: ${disciplina.id}' : 'Nova disciplina'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Excluir',
                ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
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
        return Icons.account_tree;
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