import 'package:flutter/material.dart';

class ProfessorCard extends StatelessWidget {
  final Map<String, dynamic> professorData;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ProfessorCard({
    super.key,
    required this.professorData,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final usuario = professorData['usuarios'] ?? {};
    final nome = usuario['nome'] ?? 'Professor';
    final materias = List<String>.from(professorData['materias'] ?? []);
    final valorHora = professorData['valor_hora'];
    final avaliacao = (professorData['avaliacao_media'] ?? 0.0).toDouble();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFF5C6BC0).withOpacity(0.15),
              child: Text(
                nome.isNotEmpty ? nome[0].toUpperCase() : 'P',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5C6BC0),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nome,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  if (materias.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: materias.take(3).map((m) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5C6BC0).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(m,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF5C6BC0))),
                      )).toList(),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 14, color: Colors.amber.shade600),
                      const SizedBox(width: 2),
                      Text(avaliacao > 0 ? avaliacao.toStringAsFixed(1) : 'Novo',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      if (valorHora != null) ...[
                        const SizedBox(width: 8),
                        Text('R\$ ${valorHora.toStringAsFixed(0)}/h',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF43A047),
                                fontWeight: FontWeight.w600)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            trailing ??
                (onTap != null
                    ? Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400)
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
