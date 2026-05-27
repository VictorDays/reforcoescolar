import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/usuario.dart';
import '../../models/solicitacao.dart';
import '../../controllers/solicitacao_controller.dart';
import '../../controllers/professor_controller.dart';

class AgendaScreen extends StatefulWidget {
  final Usuario usuario;
  const AgendaScreen({super.key, required this.usuario});
  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  String? _professorId;
  DateTime _mesSelecionado = DateTime.now();
  DateTime? _diaSelecionado;

  @override
  void initState() {
    super.initState();
    _diaSelecionado = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final profCtrl = context.read<ProfessorController>();
      await profCtrl.carregarPerfil(widget.usuario.id);
      _professorId = profCtrl.professorAtual?['id'];
      if (_professorId != null) {
        await context.read<SolicitacaoController>().carregarDoProfessor(_professorId!);
      }
    });
  }

  Future<void> _abrirGoogleCalendar(Solicitacao? s) async {
    DateTime inicio;
    String titulo;

    if (s != null) {
      inicio = s.horarioSolicitado ?? DateTime.now().add(const Duration(days: 1));
      titulo = 'Aula: ${s.disciplina ?? "Reforço"} com ${s.nomeAluno}';
    } else {
      inicio = _diaSelecionado != null
          ? DateTime(_diaSelecionado!.year, _diaSelecionado!.month, _diaSelecionado!.day, 10)
          : DateTime.now().add(const Duration(days: 1));
      titulo = 'Aula de Reforço';
    }

    final fim = inicio.add(const Duration(hours: 1));

    String _fmt(DateTime dt) {
      return '${dt.toUtc().toIso8601String().replaceAll('-', '').replaceAll(':', '').split('.')[0]}Z';
    }

    final url = Uri.parse(
      'https://calendar.google.com/calendar/render'
      '?action=TEMPLATE'
      '&text=${Uri.encodeComponent(titulo)}'
      '&dates=${_fmt(inicio)}/${_fmt(fim)}'
      '&details=${Uri.encodeComponent("Aula agendada pelo app Reforço Escolar")}'
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o Google Calendar')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
        title: const Text('Agenda', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Adicionar ao Google Calendar',
            onPressed: () => _abrirGoogleCalendar(null),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendario(),
          const Divider(height: 1),
          Expanded(child: _buildAulasAprovadas()),
        ],
      ),
    );
  }

  // ─── CALENDÁRIO ───────────────────────────────────────────────────────────
  Widget _buildCalendario() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeaderMes(),
          const SizedBox(height: 12),
          _buildDiasSemanaCabecalho(),
          const SizedBox(height: 8),
          _buildGradeCalendario(),
        ],
      ),
    );
  }

  Widget _buildHeaderMes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: () => setState(() {
            _mesSelecionado = DateTime(_mesSelecionado.year, _mesSelecionado.month - 1);
          }),
        ),
        Text(
          '${_nomeMes(_mesSelecionado.month)} ${_mesSelecionado.year}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: () => setState(() {
            _mesSelecionado = DateTime(_mesSelecionado.year, _mesSelecionado.month + 1);
          }),
        ),
      ],
    );
  }

  Widget _buildDiasSemanaCabecalho() {
    const dias = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
    return Row(
      children: dias.map((d) => Expanded(
        child: Center(
          child: Text(d, style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.grey.shade500, fontSize: 13)),
        ),
      )).toList(),
    );
  }

  Widget _buildGradeCalendario() {
    final primeiroDia = DateTime(_mesSelecionado.year, _mesSelecionado.month, 1);
    final diasNoMes = DateTime(_mesSelecionado.year, _mesSelecionado.month + 1, 0).day;
    final inicioSemana = primeiroDia.weekday % 7;
    final hoje = DateTime.now();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: 44,
      ),
      itemCount: inicioSemana + diasNoMes,
      itemBuilder: (ctx, i) {
        if (i < inicioSemana) return const SizedBox.shrink();
        final dia = i - inicioSemana + 1;
        final data = DateTime(_mesSelecionado.year, _mesSelecionado.month, dia);
        final isHoje = data.day == hoje.day && data.month == hoje.month && data.year == hoje.year;
        final isSelecionado = _diaSelecionado != null &&
            data.day == _diaSelecionado!.day &&
            data.month == _diaSelecionado!.month &&
            data.year == _diaSelecionado!.year;

        return GestureDetector(
          onTap: () => setState(() => _diaSelecionado = data),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelecionado
                  ? const Color(0xFF5C6BC0)
                  : isHoje
                      ? const Color(0xFF5C6BC0).withOpacity(0.12)
                      : null,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$dia',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelecionado || isHoje ? FontWeight.bold : FontWeight.normal,
                  color: isSelecionado ? Colors.white : isHoje ? const Color(0xFF5C6BC0) : Colors.black87,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── AULAS APROVADAS ──────────────────────────────────────────────────────
  Widget _buildAulasAprovadas() {
    return Consumer<SolicitacaoController>(
      builder: (ctx, ctrl, _) {
        if (ctrl.isLoading) return const Center(child: CircularProgressIndicator());

        final aprovadas = ctrl.aprovadas;

        if (aprovadas.isEmpty) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.event_available_rounded, size: 56, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text('Nenhuma aula agendada ainda',
                  style: TextStyle(color: Colors.grey.shade500)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _abrirGoogleCalendar(null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C6BC0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.calendar_month_rounded, size: 18),
                label: const Text('Abrir Google Calendar'),
              ),
            ]),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Aulas Confirmadas',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  TextButton.icon(
                    onPressed: () => _abrirGoogleCalendar(null),
                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                    label: const Text('Abrir Calendar'),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF5C6BC0)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: aprovadas.length,
                itemBuilder: (ctx, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildAulaCard(aprovadas[i]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAulaCard(Solicitacao s) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        border: Border.all(color: const Color(0xFF43A047).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF43A047).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_circle_rounded, color: Color(0xFF43A047), size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.nomeAluno,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                if (s.disciplina != null)
                  Text(s.disciplina!,
                      style: const TextStyle(color: Color(0xFF5C6BC0), fontSize: 12)),
                if (s.mensagem != null && s.mensagem!.isNotEmpty)
                  Text(s.mensagem!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded, color: Color(0xFF5C6BC0), size: 22),
            tooltip: 'Adicionar ao Google Calendar',
            onPressed: () => _abrirGoogleCalendar(s),
          ),
        ],
      ),
    );
  }

  String _nomeMes(int mes) {
    const meses = ['Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'];
    return meses[mes - 1];
  }
}
