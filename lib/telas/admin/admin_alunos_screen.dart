import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/admin_controller.dart';

class AdminAlunosScreen extends StatefulWidget {
  const AdminAlunosScreen({super.key});

  @override
  State<AdminAlunosScreen> createState() => _AdminAlunosScreenState();
}

class _AdminAlunosScreenState extends State<AdminAlunosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().carregarAlunos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF5C6BC0)));
        }

        final alunos = controller.alunos;

        if (alunos.isEmpty) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.person_outline_rounded, size: 72, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text('Nenhum aluno cadastrado',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
              const SizedBox(height: 6),
              Text('Alunos aparecem aqui após o cadastro',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
            ]),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: alunos.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildCard(context, alunos[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, Map<String, dynamic> aluno) {
    final usuario = aluno['usuarios'] as Map<String, dynamic>? ?? {};
    final nome = usuario['nome'] as String? ?? 'Sem nome';
    final email = usuario['email'] as String? ?? '';
    final serie = aluno['serie'] as String?;
    final escola = aluno['escola'] as String?;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF5C6BC0).withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              nome.isNotEmpty ? nome[0].toUpperCase() : 'A',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5C6BC0),
              ),
            ),
          ),
        ),
        title: Text(nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(email, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            if (serie != null || escola != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  if (serie != null && serie.isNotEmpty) ...[
                    Icon(Icons.class_rounded, size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 3),
                    Text(serie, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  ],
                  if (serie != null && serie.isNotEmpty && escola != null && escola.isNotEmpty)
                    Text('  •  ', style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                  if (escola != null && escola.isNotEmpty) ...[
                    Icon(Icons.account_balance_rounded, size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(escola,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_rounded, color: Color(0xFFE53935), size: 20),
          onPressed: () => _confirmarDelecao(context, aluno['id']),
        ),
      ),
    );
  }

  void _confirmarDelecao(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Excluir aluno?'),
        content: const Text('Deseja excluir este aluno? Esta ação não pode ser desfeita.'),
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
              await adminCtrl.deletarAluno(id);
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Aluno excluído!'),
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
