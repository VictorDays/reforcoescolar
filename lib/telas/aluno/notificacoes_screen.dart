import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/usuario.dart';
import '../../models/solicitacao.dart';
import '../../controllers/solicitacao_controller.dart';
import '../../controllers/aluno_controller.dart';

class NotificacoesScreen extends StatefulWidget {
  final Usuario usuario;
  const NotificacoesScreen({super.key, required this.usuario});

  @override
  State<NotificacoesScreen> createState() => _NotificacoesScreenState();
}

class _NotificacoesScreenState extends State<NotificacoesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final alunoCtrl = context.read<AlunoController>();
      final solCtrl = context.read<SolicitacaoController>();
      if (alunoCtrl.alunoAtual == null) {
        await alunoCtrl.carregarPerfil(widget.usuario.id);
      }
      final alunoId = alunoCtrl.alunoAtual?['id'];
      if (alunoId != null) {
        await solCtrl.carregarDoAluno(alunoId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
        title: const Text('Notificações', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Consumer<SolicitacaoController>(
        builder: (ctx, ctrl, _) {
          if (ctrl.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF5C6BC0)));
          }

          final aprovadas = ctrl.solicitacoes.where((s) => s.isAprovada).toList();

          if (aprovadas.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.notifications_none_rounded, size: 72, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('Nenhuma notificação ainda',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                Text('Aqui aparecerão as confirmações de aulas',
                    style: TextStyle(color: Colors.grey.shade400)),
              ]),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFF5C6BC0),
            onRefresh: () async {
              final alunoCtrl = context.read<AlunoController>();
              final id = alunoCtrl.alunoAtual?['id'];
              if (id != null) await ctrl.carregarDoAluno(id);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: aprovadas.length,
              itemBuilder: (ctx, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildNotificacao(aprovadas[i]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificacao(Solicitacao s) {
    final profUsuario = s.professorData?['usuarios'] as Map<String, dynamic>?;
    final nomeProf = profUsuario?['nome'] ?? 'Professor';
    final data = s.dataConfirmada;
    final isNova = s.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 3)));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)],
        border: Border.all(color: const Color(0xFF43A047).withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF43A047).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF43A047), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(
                      child: Text(
                        'Aula confirmada!',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    if (isNova)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5C6BC0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('Nova',
                            style: TextStyle(color: Colors.white, fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                  ]),
                  const SizedBox(height: 2),
                  Text(
                    'Prof. $nomeProf${s.disciplina != null ? " · ${s.disciplina}" : ""}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ]),
              ),
            ]),

            const SizedBox(height: 12),

            if (data != null)
              _infoChip(Icons.calendar_today_rounded,
                  '${data.day.toString().padLeft(2,'0')}/${data.month.toString().padLeft(2,'0')}/${data.year}  •  ${data.hour.toString().padLeft(2,'0')}:${data.minute.toString().padLeft(2,'0')}',
                  const Color(0xFFFF8F00)),

            if (s.linkAula != null && s.linkAula!.isNotEmpty) ...[
              const SizedBox(height: 6),
              _infoChip(Icons.videocam_rounded, s.linkAula!, const Color(0xFF5C6BC0)),
            ],

            if (s.emailProfessor.isNotEmpty) ...[
              const SizedBox(height: 6),
              _infoChip(Icons.email_rounded, s.emailProfessor, const Color(0xFF5C6BC0)),
            ],

            if (s.respostaProfessor != null && s.respostaProfessor!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF43A047).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF43A047).withValues(alpha: 0.2)),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.format_quote_rounded, color: Color(0xFF43A047), size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(s.respostaProfessor!,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF2E7D32))),
                  ),
                ]),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF5C6BC0),
                  side: const BorderSide(color: Color(0xFF5C6BC0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                icon: const Icon(Icons.menu_book_rounded, size: 18),
                label: const Text('Ver em Minhas Aulas',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Row(children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 6),
      Expanded(
        child: Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            overflow: TextOverflow.ellipsis),
      ),
    ]);
  }
}
