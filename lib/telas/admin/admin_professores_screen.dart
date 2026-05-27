import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/admin_controller.dart';

class AdminProfessoresScreen extends StatefulWidget {
  const AdminProfessoresScreen({super.key});

  @override
  State<AdminProfessoresScreen> createState() => _AdminProfessoresScreenState();
}

class _AdminProfessoresScreenState extends State<AdminProfessoresScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().carregarProfessores();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF5C6BC0)));
        }

        final professores = controller.professores;

        if (professores.isEmpty) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.school_outlined, size: 72, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text('Nenhum professor cadastrado',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
              const SizedBox(height: 6),
              Text('Professores aparecem aqui após o cadastro',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
            ]),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: professores.length,
          itemBuilder: (context, index) {
            final professor = professores[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildCard(context, professor),
            );
          },
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, Map<String, dynamic> professor) {
    final usuario = professor['usuarios'] as Map<String, dynamic>? ?? {};
    final nome = usuario['nome'] as String? ?? 'Sem nome';
    final email = usuario['email'] as String? ?? '';
    final materias = List<String>.from(professor['materias'] ?? []);
    final valorHora = professor['valor_hora'];
    final tipoAula = professor['tipo_aula'] as String? ?? 'ambos';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF43A047).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  nome.isNotEmpty ? nome[0].toUpperCase() : 'P',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF43A047),
                  ),
                ),
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
                        child: Text(nome,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_rounded, color: Color(0xFFE53935), size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _confirmarDelecao(context, professor['id']),
                      ),
                    ],
                  ),
                  Text(email, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  const SizedBox(height: 8),
                  if (materias.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: materias.take(4).map((m) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF43A047).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(m,
                            style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF43A047),
                                fontWeight: FontWeight.w600)),
                      )).toList(),
                    )
                  else
                    Text('Sem disciplinas cadastradas',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (valorHora != null) ...[
                        Icon(Icons.attach_money_rounded, size: 14, color: Colors.grey.shade500),
                        Text(
                          'R\$${(valorHora as num).toStringAsFixed(0)}/h',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Icon(
                        tipoAula == 'online'
                            ? Icons.videocam_rounded
                            : tipoAula == 'presencial'
                                ? Icons.location_on_rounded
                                : Icons.swap_horiz_rounded,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tipoAula[0].toUpperCase() + tipoAula.substring(1),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarDelecao(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Excluir professor?'),
        content: const Text('Deseja excluir este professor? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final adminCtrl = context.read<AdminController>();
              final messenger = ScaffoldMessenger.of(context);
              await adminCtrl.deletarProfessor(id);
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Professor excluído!'),
                  backgroundColor: Color(0xFF43A047),
                ),
              );
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
