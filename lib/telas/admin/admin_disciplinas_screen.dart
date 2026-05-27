import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/admin_controller.dart';

class AdminDisciplinasScreen extends StatefulWidget {
  const AdminDisciplinasScreen({super.key});

  @override
  State<AdminDisciplinasScreen> createState() => _AdminDisciplinasScreenState();
}

class _AdminDisciplinasScreenState extends State<AdminDisciplinasScreen> {
  final _nomeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  static const List<Color> _cores = [
    Color(0xFF5C6BC0), Color(0xFF43A047), Color(0xFFE53935),
    Color(0xFFFF8F00), Color(0xFF00897B), Color(0xFF8E24AA),
    Color(0xFF039BE5), Color(0xFFD81B60),
  ];

  static const List<IconData> _icones = [
    Icons.calculate_rounded, Icons.book_rounded, Icons.science_rounded,
    Icons.biotech_rounded, Icons.history_edu_rounded, Icons.translate_rounded,
    Icons.music_note_rounded, Icons.palette_rounded,
  ];

  Color _corPara(String nome) => _cores[nome.codeUnits.first % _cores.length];
  IconData _iconePara(String nome) => _icones[nome.codeUnits.first % _icones.length];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().carregarDisciplinas();
    });
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF5C6BC0)));
        }

        final disciplinas = controller.disciplinas;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _abrirDialog(context),
            backgroundColor: const Color(0xFF5C6BC0),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text('Nova', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          body: disciplinas.isEmpty
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.book_outlined, size: 72, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text('Nenhuma disciplina cadastrada',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                  ]),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: disciplinas.length,
                  itemBuilder: (ctx, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildCard(context, disciplinas[i]),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, Map<String, dynamic> d) {
    final nome = d['nome'] as String;
    final descricao = d['descricao'] as String?;
    final ativa = d['ativa'] as bool? ?? true;
    final cor = _corPara(nome);
    final icone = _iconePara(nome);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))
        ],
        border: ativa ? null : Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: ativa ? cor : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icone, color: ativa ? Colors.white : Colors.grey.shade400, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nome,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: ativa ? Colors.black87 : Colors.grey.shade400,
                    ),
                  ),
                  if (descricao != null && descricao.isNotEmpty)
                    Text(
                      descricao,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                ],
              ),
            ),
            Switch(
              value: ativa,
              activeThumbColor: cor,
              activeTrackColor: cor.withValues(alpha: 0.4),
              onChanged: (v) => context.read<AdminController>().atualizarDisciplina(
                    d['id'], nome, descricao, v),
            ),
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: Color(0xFF5C6BC0), size: 20),
              onPressed: () => _abrirDialog(context, disciplina: d),
            ),
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: Color(0xFFE53935), size: 20),
              onPressed: () => _confirmarDelete(context, d),
            ),
          ],
        ),
      ),
    );
  }

  void _abrirDialog(BuildContext context, {Map<String, dynamic>? disciplina}) {
    if (disciplina != null) {
      _nomeCtrl.text = disciplina['nome'];
      _descCtrl.text = disciplina['descricao'] ?? '';
    } else {
      _nomeCtrl.clear();
      _descCtrl.clear();
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          disciplina == null ? 'Nova Disciplina' : 'Editar Disciplina',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nomeCtrl,
              decoration: InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Descrição (opcional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5C6BC0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              if (_nomeCtrl.text.trim().isEmpty) return;
              final ctrl = context.read<AdminController>();
              final messenger = ScaffoldMessenger.of(context);
              final nome = _nomeCtrl.text.trim();
              final desc = _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim();
              Navigator.pop(ctx);
              if (disciplina == null) {
                await ctrl.adicionarDisciplina(nome, desc);
                messenger.showSnackBar(
                  const SnackBar(content: Text('Disciplina adicionada!'), backgroundColor: Color(0xFF43A047)));
              } else {
                await ctrl.atualizarDisciplina(disciplina['id'], nome, desc, disciplina['ativa'] ?? true);
                messenger.showSnackBar(
                  const SnackBar(content: Text('Disciplina atualizada!'), backgroundColor: Color(0xFF43A047)));
              }
            },
            child: Text(disciplina == null ? 'Adicionar' : 'Salvar'),
          ),
        ],
      ),
    );
  }

  void _confirmarDelete(BuildContext context, Map<String, dynamic> d) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Excluir disciplina?'),
        content: Text('Deseja excluir "${d['nome']}"?'),
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
              final ctrl = context.read<AdminController>();
              final messenger = ScaffoldMessenger.of(context);
              await ctrl.deletarDisciplina(d['id']);
              messenger.showSnackBar(
                const SnackBar(content: Text('Disciplina excluída!'), backgroundColor: Color(0xFF43A047)));
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
