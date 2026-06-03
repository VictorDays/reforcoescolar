import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/usuario.dart';
import '../../models/solicitacao.dart';
import '../../controllers/solicitacao_controller.dart';
import '../../controllers/aluno_controller.dart';

class MinhasAulasScreen extends StatefulWidget {
  final Usuario usuario;
  const MinhasAulasScreen({super.key, required this.usuario});
  @override
  State<MinhasAulasScreen> createState() => _MinhasAulasScreenState();
}

class _MinhasAulasScreenState extends State<MinhasAulasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String? _alunoId;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final alunoCtrl = context.read<AlunoController>();
      final solCtrl = context.read<SolicitacaoController>();
      await alunoCtrl.carregarPerfil(widget.usuario.id);
      _alunoId = alunoCtrl.alunoAtual?['id'];
      if (_alunoId != null) {
        await solCtrl.carregarDoAluno(_alunoId!);
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
        title: const Text('Minhas Aulas', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Pendentes'),
            Tab(text: 'Aprovadas'),
            Tab(text: 'Recusadas'),
          ],
        ),
      ),
      body: Consumer<SolicitacaoController>(
        builder: (ctx, ctrl, _) {
          if (ctrl.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF5C6BC0)));
          }

          final pendentes = ctrl.solicitacoes.where((s) => s.isPendente).toList();
          final aprovadas = ctrl.solicitacoes.where((s) => s.isAprovada).toList();
          final recusadas = ctrl.solicitacoes.where((s) => s.isRecusada).toList();

          return TabBarView(
            controller: _tabCtrl,
            children: [
              _buildLista(pendentes, emptyMsg: 'Nenhuma solicitação pendente',
                  emptyIcon: Icons.hourglass_empty_rounded),
              _buildLista(aprovadas, emptyMsg: 'Nenhuma aula aprovada ainda',
                  emptyIcon: Icons.event_available_rounded),
              _buildLista(recusadas, emptyMsg: 'Nenhuma solicitação recusada',
                  emptyIcon: Icons.event_busy_rounded),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLista(List<Solicitacao> lista,
      {required String emptyMsg, required IconData emptyIcon}) {
    if (lista.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(emptyIcon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(emptyMsg, style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
        ]),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF5C6BC0),
      onRefresh: () async {
        if (_alunoId != null) {
          await context.read<SolicitacaoController>().carregarDoAluno(_alunoId!);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: lista.length,
        itemBuilder: (ctx, i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildCard(lista[i]),
        ),
      ),
    );
  }

  Widget _buildCard(Solicitacao s) {
    final profUsuario = s.professorData?['usuarios'] as Map<String, dynamic>?;
    final nomeProf = profUsuario?['nome'] ?? 'Professor';

    final Color statusColor = s.isAprovada
        ? const Color(0xFF43A047)
        : s.isRecusada
            ? const Color(0xFFE53935)
            : const Color(0xFFFF8F00);

    final String statusLabel =
        s.isPendente ? 'Pendente' : s.isAprovada ? 'Aprovada' : 'Recusada';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: s.isAprovada ? () => _mostrarDetalhesAula(s, nomeProf) : null,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)],
            border: s.isAprovada
                ? Border.all(color: const Color(0xFF43A047).withValues(alpha: 0.3))
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF5C6BC0).withValues(alpha: 0.1),
                    child: Text(
                      nomeProf.isNotEmpty ? nomeProf[0].toUpperCase() : 'P',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Color(0xFF5C6BC0), fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(nomeProf,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      if (s.disciplina != null)
                        Row(children: [
                          const Icon(Icons.book_rounded, size: 13, color: Color(0xFF5C6BC0)),
                          const SizedBox(width: 4),
                          Text(s.disciplina!,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF5C6BC0), fontWeight: FontWeight.w600)),
                        ]),
                    ]),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(statusLabel,
                        style: TextStyle(
                            fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
                  ),
                ]),
                if (s.mensagem != null && s.mensagem!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('"${s.mensagem}"',
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                            fontStyle: FontStyle.italic)),
                  ),
                ],
                if (s.isAprovada) ...[
                  const SizedBox(height: 10),
                  Row(children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF43A047), size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text('Aula confirmada! Toque para ver detalhes',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12,
                              fontWeight: FontWeight.w500)),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Color(0xFF43A047), size: 18),
                  ]),
                ],
                if (s.isPendente) ...[
                  const SizedBox(height: 10),
                  Row(children: [
                    const Icon(Icons.schedule_rounded, color: Color(0xFFFF8F00), size: 16),
                    const SizedBox(width: 6),
                    Text('Aguardando resposta do professor',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ]),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarDetalhesAula(Solicitacao s, String nomeProf) {
    final data = s.dataConfirmada;
    final link = s.linkAula;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF43A047).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.event_available_rounded,
                      color: Color(0xFF43A047), size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Aula Confirmada',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(nomeProf,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                  ]),
                ),
                IconButton(
                    icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ]),
              const SizedBox(height: 20),

              if (s.disciplina != null) ...[
                _detalheRow(Icons.book_rounded, 'Disciplina', s.disciplina!,
                    const Color(0xFF5C6BC0)),
                const SizedBox(height: 12),
              ],

              if (data != null) ...[
                _detalheRow(
                  Icons.calendar_today_rounded,
                  'Data e Horário',
                  '${data.day.toString().padLeft(2,'0')}/${data.month.toString().padLeft(2,'0')}/${data.year}  •  ${data.hour.toString().padLeft(2,'0')}:${data.minute.toString().padLeft(2,'0')}',
                  const Color(0xFFFF8F00),
                ),
                const SizedBox(height: 12),
              ] else ...[
                _detalheRow(Icons.calendar_today_rounded, 'Data e Horário',
                    'A combinar com o professor', Colors.grey),
                const SizedBox(height: 12),
              ],

              if (link != null && link.isNotEmpty) ...[
                _detalheRow(Icons.videocam_rounded, 'Link da Aula', link,
                    const Color(0xFF5C6BC0)),
                const SizedBox(height: 12),
              ] else ...[
                _detalheRow(Icons.videocam_off_rounded, 'Modalidade',
                    'Aula presencial', Colors.grey),
                const SizedBox(height: 12),
              ],

              if (s.respostaProfessor != null && s.respostaProfessor!.isNotEmpty) ...[
                _detalheRow(Icons.chat_bubble_rounded, 'Mensagem do professor',
                    s.respostaProfessor!, const Color(0xFF43A047)),
                const SizedBox(height: 12),
              ],
              if (s.emailProfessor.isNotEmpty) ...[
                _detalheRow(Icons.email_rounded, 'E-mail do professor',
                    s.emailProfessor, const Color(0xFF5C6BC0)),
                const SizedBox(height: 12),
              ],
              if (s.mensagem != null && s.mensagem!.isNotEmpty) ...[
                _detalheRow(Icons.message_rounded, 'Sua mensagem', s.mensagem!,
                    Colors.grey),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detalheRow(IconData icon, String label, String valor, Color color) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          const SizedBox(height: 2),
          Text(valor,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ]),
      ),
    ]);
  }
}
