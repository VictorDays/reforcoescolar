import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/novidade_controller.dart';
import '../../models/novidade.dart';

class AdminNovidades extends StatefulWidget {
  const AdminNovidades({super.key});
  @override
  State<AdminNovidades> createState() => _AdminNovidades();
}

class _AdminNovidades extends State<AdminNovidades> {
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  int _corSelecionada = 0xFF5C6BC0;

  final List<Map<String, dynamic>> _cores = [
    {'hex': 0xFF5C6BC0, 'label': 'Índigo'},
    {'hex': 0xFF43A047, 'label': 'Verde'},
    {'hex': 0xFFE53935, 'label': 'Vermelho'},
    {'hex': 0xFFFF8F00, 'label': 'Âmbar'},
    {'hex': 0xFF00897B, 'label': 'Teal'},
    {'hex': 0xFF8E24AA, 'label': 'Roxo'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NovidadeController>().carregarTodas();
    });
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _abrirDialog({Novidade? novidade}) {
    if (novidade != null) {
      _tituloCtrl.text = novidade.titulo;
      _descCtrl.text = novidade.descricao;
      _corSelecionada = novidade.corHex;
    } else {
      _tituloCtrl.clear();
      _descCtrl.clear();
      _corSelecionada = 0xFF5C6BC0;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(novidade == null ? 'Nova Novidade' : 'Editar Novidade'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _tituloCtrl,
                  decoration: InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Cor do Card', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _cores.map((c) {
                    final isSelected = _corSelecionada == c['hex'];
                    return GestureDetector(
                      onTap: () => setDialogState(() => _corSelecionada = c['hex'] as int),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Color(c['hex'] as int),
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
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
                if (_tituloCtrl.text.isEmpty || _descCtrl.text.isEmpty) return;
                final ctrl = context.read<NovidadeController>();
                if (novidade == null) {
                  await ctrl.criar(_tituloCtrl.text.trim(), _descCtrl.text.trim(), _corSelecionada);
                } else {
                  await ctrl.atualizar(novidade.id, _tituloCtrl.text.trim(), _descCtrl.text.trim(), _corSelecionada, novidade.ativa);
                }
                Navigator.pop(ctx);
              },
              child: Text(novidade == null ? 'Criar' : 'Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirDialog(),
        backgroundColor: const Color(0xFF5C6BC0),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nova', style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<NovidadeController>(
        builder: (ctx, ctrl, _) {
          if (ctrl.isLoading) return const Center(child: CircularProgressIndicator());
          if (ctrl.novidades.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.campaign_outlined, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text('Nenhuma novidade cadastrada', style: TextStyle(color: Colors.grey.shade500)),
              ]),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ctrl.novidades.length,
            itemBuilder: (ctx, i) {
              final n = ctrl.novidades[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: n.cor, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.campaign, color: Colors.white),
                  ),
                  title: Text(n.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(n.descricao, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade600)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: n.ativa,
                        activeColor: const Color(0xFF5C6BC0),
                        onChanged: (v) => ctrl.atualizar(n.id, n.titulo, n.descricao, n.corHex, v),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, color: Color(0xFF5C6BC0)),
                        onPressed: () => _abrirDialog(novidade: n),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_rounded, color: Colors.red),
                        onPressed: () => _confirmarDelete(n),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmarDelete(Novidade n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir novidade?'),
        content: Text('Deseja excluir "${n.titulo}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              context.read<NovidadeController>().deletar(n.id);
              Navigator.pop(ctx);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
