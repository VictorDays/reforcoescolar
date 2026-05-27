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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
                Text('Aula confirmada pelo professor!',
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500)),
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
    );
  }
}
