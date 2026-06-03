import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/usuario.dart';
import '../../controllers/favorito_controller.dart';
import '../../controllers/solicitacao_controller.dart';
import '../../controllers/aluno_controller.dart';

class ProfessorDetalheScreen extends StatefulWidget {
  final Map<String, dynamic> professorData;
  final Usuario usuario;

  const ProfessorDetalheScreen({
    super.key,
    required this.professorData,
    required this.usuario,
  });

  @override
  State<ProfessorDetalheScreen> createState() => _ProfessorDetalheScreenState();
}

class _ProfessorDetalheScreenState extends State<ProfessorDetalheScreen> {
  String? _alunoId;
  bool _enviandoSolicitacao = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final alunoCtrl = context.read<AlunoController>();
      await alunoCtrl.carregarPerfil(widget.usuario.id);
      _alunoId = alunoCtrl.alunoAtual?['id'];

      if (_alunoId != null) {
        await context.read<FavoritoController>().carregarFavoritos(_alunoId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final prof = widget.professorData;
    final usuario = prof['usuarios'] ?? {};
    final nome = usuario['nome'] ?? 'Professor';
    final materias = List<String>.from(prof['materias'] ?? []);
    final descricao = prof['descricao'] as String?;
    final valorHora = prof['valor_hora'];
    final avaliacao = (prof['avaliacao_media'] ?? 0.0).toDouble();
    final totalAvaliacoes = prof['total_avaliacoes'] ?? 0;
    final tipoAula = prof['tipo_aula'] ?? 'ambos';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(nome, materias),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(avaliacao, totalAvaliacoes, valorHora, tipoAula),
                  if (descricao != null && descricao.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildDescricaoCard(descricao),
                  ],
                  if (materias.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildMateriasCard(materias),
                  ],
                  const SizedBox(height: 24),
                  _buildBotaoSolicitacao(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(String nome, List<String> materias) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: const Color(0xFF5C6BC0),
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF5C6BC0), Color(0xFF3949AB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 46,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  nome.isNotEmpty ? nome[0].toUpperCase() : 'P',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              Text(nome,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                materias.take(2).join(' • '),
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Consumer<FavoritoController>(
          builder: (ctx, ctrl, _) {
            final profId = widget.professorData['id'] as String;
            final fav = ctrl.isFavorito(profId);
            return IconButton(
              icon: Icon(fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: fav ? Colors.red.shade300 : Colors.white),
              onPressed: _alunoId == null
                  ? null
                  : () => ctrl.toggleFavorito(_alunoId!, profId),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoCard(double avaliacao, int totalAvaliacoes, dynamic valorHora, String tipoAula) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _infoItem(Icons.star_rounded, Colors.amber.shade600,
              avaliacao > 0 ? avaliacao.toStringAsFixed(1) : '–', 'Avaliação'),
          _divider(),
          _infoItem(Icons.people_rounded, const Color(0xFF5C6BC0),
              '$totalAvaliacoes', 'Avaliações'),
          _divider(),
          _infoItem(Icons.attach_money_rounded, const Color(0xFF43A047),
              valorHora != null ? 'R\$${(valorHora as num).toStringAsFixed(0)}/h' : 'A combinar',
              'Valor'),
          _divider(),
          _infoItem(
            tipoAula == 'presencial'
                ? Icons.location_on_rounded
                : tipoAula == 'online'
                    ? Icons.videocam_rounded
                    : Icons.swap_horiz_rounded,
            const Color(0xFFE53935),
            tipoAula == 'ambos' ? 'Ambos' : tipoAula[0].toUpperCase() + tipoAula.substring(1),
            'Modalidade',
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, Color color, String value, String label) {
    return Column(children: [
      Icon(icon, color: color, size: 24),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
    ]);
  }

  Widget _divider() => Container(width: 1, height: 40, color: Colors.grey.shade200);

  Widget _buildDescricaoCard(String descricao) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sobre o professor',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          Text(descricao, style: TextStyle(color: Colors.grey.shade700, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildMateriasCard(List<String> materias) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Disciplinas',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: materias.map((m) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF5C6BC0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(m,
                  style: const TextStyle(
                      color: Color(0xFF5C6BC0),
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBotaoSolicitacao() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _enviandoSolicitacao ? null : _abrirDialogSolicitacao,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5C6BC0),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 2,
        ),
        icon: _enviandoSolicitacao
            ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.send_rounded),
        label: Text(
          _enviandoSolicitacao ? 'Enviando...' : 'Solicitar Aula',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _abrirDialogSolicitacao() {
    if (_alunoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil de aluno não encontrado')));
      return;
    }

    final msgCtrl = TextEditingController();
    String? disciplinaSelecionada;
    final materias = List<String>.from(widget.professorData['materias'] ?? []);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setBottomState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 24, right: 24, top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.school_rounded, color: Color(0xFF5C6BC0)),
                const SizedBox(width: 8),
                const Text('Solicitar Aula',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ]),
              const SizedBox(height: 16),

              if (materias.isNotEmpty) ...[
                const Text('Disciplina', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: disciplinaSelecionada,
                  hint: const Text('Selecione a disciplina'),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: materias.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (v) => setBottomState(() => disciplinaSelecionada = v),
                ),
                const SizedBox(height: 12),
              ],

              const Text('Mensagem (opcional)', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: msgCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Descreva suas dificuldades ou preferências...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C6BC0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    setState(() => _enviandoSolicitacao = true);
                    final solCtrl = context.read<SolicitacaoController>();
                    final ok = await solCtrl.enviarSolicitacao(
                      alunoId: _alunoId!,
                      professorId: widget.professorData['id'],
                      mensagem: msgCtrl.text.trim().isEmpty ? null : msgCtrl.text.trim(),
                      disciplina: disciplinaSelecionada,
                    );
                    if (ok && _alunoId != null) {
                      await solCtrl.carregarDoAluno(_alunoId!);
                    }
                    setState(() => _enviandoSolicitacao = false);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(ok ? 'Solicitação enviada!' : (solCtrl.erro ?? 'Erro ao enviar solicitação')),
                        backgroundColor: ok ? const Color(0xFF43A047) : Colors.red,
                      ));
                    }
                  },
                  child: const Text('Enviar Solicitação',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
