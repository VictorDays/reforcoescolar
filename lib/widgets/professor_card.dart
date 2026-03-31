// lib/widgets/professor_card.dart
import 'package:flutter/material.dart';
import '../modelos/professor.dart';

class ProfessorCard extends StatelessWidget {
  final Professor professor;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleAtivo;

  const ProfessorCard({
    super.key,
    required this.professor,
    this.onTap,
    this.onDelete,
    this.onToggleAtivo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: professor.ativo 
                    ? Colors.green.shade100 
                    : Colors.grey.shade200,
                child: Icon(
                  Icons.person,
                  size: 35,
                  color: professor.ativo ? Colors.green : Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            professor.nome,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: professor.ativo 
                                  ? TextDecoration.none 
                                  : TextDecoration.lineThrough,
                              color: professor.ativo 
                                  ? Colors.black87 
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        if (onToggleAtivo != null)
                          Switch(
                            value: professor.ativo,
                            onChanged: (_) => onToggleAtivo!(),
                            activeColor: Colors.green,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      professor.disciplina,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'R\$ ${professor.valor.toStringAsFixed(2)}/hora',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    if (professor.descricao.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        professor.descricao,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Excluir',
                ),
            ],
          ),
        ),
      ),
    );
  }
}