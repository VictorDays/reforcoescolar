import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/usuario.dart';
import '../../models/solicitacao.dart';
import '../../controllers/solicitacao_controller.dart';
import '../../controllers/professor_controller.dart';

class SolicitacoesScreen extends StatefulWidget {
  final Usuario usuario;
  const SolicitacoesScreen({super.key, required this.usuario});
  @override
  State<SolicitacoesScreen> createState() => _SolicitacoesScreenState();
}

class _SolicitacoesScreenState extends State<SolicitacoesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String? _professorId;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final profCtrl = context.read<ProfessorController>();
      await profCtrl.carregarPerfil(widget.usuario.id);
      _professorId = profCtrl.professorAtual?['id'];
      if (_professorId != null) {
        await context.read<SolicitacaoController>().carregarDoProfessor(_professorId!);
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
        title: const Text('Solicitações', style: TextStyle(fontWeight: FontWeight.bold)),
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
              _buildLista(pendentes, showAcoes: true),
              _buildLista(aprovadas),
              _buildLista(recusadas),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLista(List<Solicitacao> lista, {bool showAcoes = false}) {
    if (lista.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text('Nenhuma solicitação aqui',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
        ]),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF5C6BC0),
      onRefresh: () async {
        if (_professorId != null) {
          await context.read<SolicitacaoController>().carregarDoProfessor(_professorId!);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: lista.length,
        itemBuilder: (ctx, i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildCard(lista[i], showAcoes: showAcoes),
        ),
      ),
    );
  }

  Widget _buildCard(Solicitacao s, {bool showAcoes = false}) {
    final Color statusColor = s.isAprovada
        ? const Color(0xFF43A047)
        : s.isRecusada
            ? const Color(0xFFE53935)
            : const Color(0xFFFF8F00);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: s.isAprovada ? () => _abrirDialogEdicaoAula(s) : null,
        child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)],
        border: s.isAprovada
            ? Border.all(color: const Color(0xFF43A047).withValues(alpha: 0.3))
            : null,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFF5C6BC0).withValues(alpha: 0.1),
                  child: Text(
                    s.nomeAluno.isNotEmpty ? s.nomeAluno[0].toUpperCase() : 'A',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF5C6BC0), fontSize: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.nomeAluno,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(s.emailAluno,
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      if (s.disciplina != null) ...[
                        const SizedBox(height: 4),
                        Row(children: [
                          Icon(Icons.book_rounded, size: 14, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(s.disciplina!,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF5C6BC0), fontWeight: FontWeight.w600)),
                        ]),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    s.isPendente ? 'Pendente' : s.isAprovada ? 'Aprovada' : 'Recusada',
                    style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          if (s.mensagem != null && s.mensagem!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(s.mensagem!,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontStyle: FontStyle.italic)),
            ),
          if (showAcoes) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final ctrl = context.read<SolicitacaoController>();
                        final messenger = ScaffoldMessenger.of(context);
                        final ok = await ctrl.recusar(s.id);
                        if (!mounted) return;
                        if (ok) {
                          _tabCtrl.animateTo(2);
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Solicitação recusada'),
                                backgroundColor: Color(0xFFE53935)));
                        } else {
                          messenger.showSnackBar(
                            SnackBar(content: Text(ctrl.erro ?? 'Erro ao recusar'),
                                backgroundColor: Colors.red));
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE53935),
                        side: const BorderSide(color: Color(0xFFE53935)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text('Recusar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _abrirDialogAprovacao(s),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF43A047),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Aprovar'),
                    ),
                  ),
                ],
              ),
            ),
          if (s.contatoAluno != null && s.contatoAluno!.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(children: [
                const Icon(Icons.phone_rounded, size: 16, color: Color(0xFF43A047)),
                const SizedBox(width: 8),
                Text('Contato: ${s.contatoAluno}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ]),
            ),
          ],
          if (s.isAprovada) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(children: [
                const Icon(Icons.edit_rounded, size: 15, color: Color(0xFF5C6BC0)),
                const SizedBox(width: 6),
                Text('Toque para editar link/horário',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ]),
            ),
          ],
        ] else
          const SizedBox(height: 8),
        ],
      ),
      ),
    ),
  );
}

void _abrirDialogEdicaoAula(Solicitacao s) {
  final linkCtrl = TextEditingController(text: s.linkAula ?? '');
  final msgCtrl = TextEditingController(text: s.respostaProfessor ?? '');
  DateTime? dataSelecionada = s.dataConfirmada;
  TimeOfDay? horaSelecionada = s.dataConfirmada != null
      ? TimeOfDay(hour: s.dataConfirmada!.hour, minute: s.dataConfirmada!.minute)
      : null;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          left: 24, right: 24, top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.edit_calendar_rounded, color: Color(0xFF5C6BC0)),
              const SizedBox(width: 8),
              const Text('Editar Aula Aprovada',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
            ]),
            const SizedBox(height: 4),
            Text('${s.nomeAluno} · ${s.disciplina ?? "Aula"}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            if (s.emailAluno.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(children: [
                  const Icon(Icons.email_rounded, size: 13, color: Color(0xFF5C6BC0)),
                  const SizedBox(width: 4),
                  Text(s.emailAluno,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF5C6BC0))),
                ]),
              ),
            const SizedBox(height: 20),

            const Text('Data e horário', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today_rounded, size: 18),
                  label: Text(dataSelecionada == null
                      ? 'Selecionar data'
                      : '${dataSelecionada!.day.toString().padLeft(2,'0')}/${dataSelecionada!.month.toString().padLeft(2,'0')}/${dataSelecionada!.year}'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5C6BC0),
                    side: const BorderSide(color: Color(0xFF5C6BC0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: dataSelecionada ?? DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (d != null) setSheet(() => dataSelecionada = d);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.access_time_rounded, size: 18),
                  label: Text(horaSelecionada == null
                      ? 'Selecionar hora'
                      : horaSelecionada!.format(ctx)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5C6BC0),
                    side: const BorderSide(color: Color(0xFF5C6BC0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () async {
                    final h = await showTimePicker(
                      context: ctx,
                      initialTime: horaSelecionada ?? const TimeOfDay(hour: 10, minute: 0),
                    );
                    if (h != null) setSheet(() => horaSelecionada = h);
                  },
                ),
              ),
            ]),
            const SizedBox(height: 16),

            const Text('Link da aula online',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: linkCtrl,
              decoration: InputDecoration(
                hintText: 'https://meet.google.com/...',
                prefixIcon: const Icon(Icons.videocam_rounded, color: Color(0xFF5C6BC0), size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Mensagem para o aluno (opcional)',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: msgCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Ex: Nos encontramos na sala 3, traga o material...',
                prefixIcon: const Icon(Icons.message_rounded, color: Color(0xFF5C6BC0), size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C6BC0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.save_rounded),
                label: const Text('Salvar Alterações',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: () async {
                  Navigator.pop(ctx);
                  DateTime? dataConfirmada;
                  if (dataSelecionada != null) {
                    final h = horaSelecionada ?? const TimeOfDay(hour: 10, minute: 0);
                    dataConfirmada = DateTime(dataSelecionada!.year, dataSelecionada!.month,
                        dataSelecionada!.day, h.hour, h.minute);
                  }
                  final ctrl = context.read<SolicitacaoController>();
                  final messenger = ScaffoldMessenger.of(context);
                  final ok = await ctrl.atualizarDetalhesAula(s.id,
                      dataConfirmada: dataConfirmada,
                      linkAula: linkCtrl.text.trim().isEmpty ? null : linkCtrl.text.trim(),
                      respostaProfessor: msgCtrl.text.trim().isEmpty ? null : msgCtrl.text.trim());
                  if (!mounted) return;
                  messenger.showSnackBar(SnackBar(
                    content: Text(ok ? 'Aula atualizada!' : (ctrl.erro ?? 'Erro ao salvar')),
                    backgroundColor: ok ? const Color(0xFF43A047) : Colors.red,
                  ));
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _abrirDialogAprovacao(Solicitacao s) {
  final linkCtrl = TextEditingController();
  final msgCtrl = TextEditingController();
  DateTime? dataSelecionada;
  TimeOfDay? horaSelecionada;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          left: 24, right: 24, top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF43A047)),
              const SizedBox(width: 8),
              const Text('Confirmar Aprovação',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
            ]),
            const SizedBox(height: 4),
            Text('${s.nomeAluno} · ${s.disciplina ?? "Aula"}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            if (s.emailAluno.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(children: [
                  const Icon(Icons.email_rounded, size: 13, color: Color(0xFF5C6BC0)),
                  const SizedBox(width: 4),
                  Text(s.emailAluno,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF5C6BC0))),
                ]),
              ),
            const SizedBox(height: 20),

            const Text('Data da aula', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today_rounded, size: 18),
                  label: Text(dataSelecionada == null
                      ? 'Selecionar data'
                      : '${dataSelecionada!.day.toString().padLeft(2, '0')}/${dataSelecionada!.month.toString().padLeft(2, '0')}/${dataSelecionada!.year}'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5C6BC0),
                    side: const BorderSide(color: Color(0xFF5C6BC0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (d != null) setSheet(() => dataSelecionada = d);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.access_time_rounded, size: 18),
                  label: Text(horaSelecionada == null
                      ? 'Selecionar hora'
                      : horaSelecionada!.format(ctx)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5C6BC0),
                    side: const BorderSide(color: Color(0xFF5C6BC0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () async {
                    final h = await showTimePicker(
                      context: ctx,
                      initialTime: const TimeOfDay(hour: 10, minute: 0),
                    );
                    if (h != null) setSheet(() => horaSelecionada = h);
                  },
                ),
              ),
            ]),
            const SizedBox(height: 16),

            const Text('Link da aula online (opcional)',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: linkCtrl,
              decoration: InputDecoration(
                hintText: 'https://meet.google.com/...',
                prefixIcon: const Icon(Icons.videocam_rounded, color: Color(0xFF5C6BC0), size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Mensagem para o aluno (opcional)',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: msgCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Ex: Nos encontramos na sala 3, traga o material...',
                prefixIcon: const Icon(Icons.message_rounded, color: Color(0xFF5C6BC0), size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF43A047),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Confirmar Aprovação',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: () async {
                  Navigator.pop(ctx);
                  DateTime? dataConfirmada;
                  if (dataSelecionada != null) {
                    final h = horaSelecionada ?? const TimeOfDay(hour: 10, minute: 0);
                    dataConfirmada = DateTime(dataSelecionada!.year, dataSelecionada!.month,
                        dataSelecionada!.day, h.hour, h.minute);
                  }
                  final ctrl = context.read<SolicitacaoController>();
                  final messenger = ScaffoldMessenger.of(context);
                  final ok = await ctrl.aprovar(s.id,
                      dataConfirmada: dataConfirmada,
                      linkAula: linkCtrl.text.trim().isEmpty ? null : linkCtrl.text.trim(),
                      respostaProfessor: msgCtrl.text.trim().isEmpty ? null : msgCtrl.text.trim());
                  if (!mounted) return;
                  if (ok) {
                    _tabCtrl.animateTo(1);
                    messenger.showSnackBar(const SnackBar(
                        content: Text('Aula aprovada!'),
                        backgroundColor: Color(0xFF43A047)));
                  } else {
                    messenger.showSnackBar(SnackBar(
                        content: Text(ctrl.erro ?? 'Erro ao aprovar'),
                        backgroundColor: Colors.red));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
