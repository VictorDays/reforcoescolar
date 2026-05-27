import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/admin_controller.dart';
import '../../services/auth_service.dart';

class AdminUsuariosScreen extends StatefulWidget {
  const AdminUsuariosScreen({super.key});

  @override
  State<AdminUsuariosScreen> createState() => _AdminUsuariosScreenState();
}

class _AdminUsuariosScreenState extends State<AdminUsuariosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().carregarUsuarios();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF5C6BC0)));
        }

        final usuarios = controller.usuarios;
        final admins = usuarios.where((u) => u['tipo'] == 'admin').length;
        final professores = usuarios.where((u) => u['tipo'] == 'professor').length;
        final alunos = usuarios.where((u) => u['tipo'] == 'aluno').length;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _abrirDialogCriarUsuario(context),
            backgroundColor: const Color(0xFF5C6BC0),
            icon: const Icon(Icons.person_add_rounded, color: Colors.white),
            label: const Text('Novo Usuário', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          body: usuarios.isEmpty
              ? _buildEmpty()
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  children: [
                    _buildStats(admins, professores, alunos, usuarios.length),
                    const SizedBox(height: 20),
                    ...usuarios.map((u) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildCard(context, u),
                        )),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildStats(int admins, int professores, int alunos, int total) {
    return Row(
      children: [
        _statChip('Total', total, const Color(0xFF5C6BC0), Icons.people_rounded),
        const SizedBox(width: 8),
        _statChip('Professores', professores, const Color(0xFF43A047), Icons.school_rounded),
        const SizedBox(width: 8),
        _statChip('Alunos', alunos, const Color(0xFFFF8F00), Icons.person_rounded),
      ],
    );
  }

  Widget _statChip(String label, int count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text('$count', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, Map<String, dynamic> u) {
    final tipo = u['tipo'] as String? ?? 'aluno';
    final (Color cor, IconData icone, String tipoLabel) = switch (tipo) {
      'admin' => (const Color(0xFF8E24AA), Icons.admin_panel_settings_rounded, 'Admin'),
      'professor' => (const Color(0xFF43A047), Icons.school_rounded, 'Professor'),
      _ => (const Color(0xFF5C6BC0), Icons.person_rounded, 'Aluno'),
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: cor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icone, color: cor, size: 22),
        ),
        title: Text(
          u['nome'] ?? 'Sem nome',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(u['email'] ?? '', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(tipoLabel, style: TextStyle(color: cor, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: Color(0xFFE53935), size: 20),
              onPressed: () => _confirmarDelecao(context, u),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.people_outline_rounded, size: 72, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text('Nenhum usuário encontrado', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
      ]),
    );
  }

  void _confirmarDelecao(BuildContext context, Map<String, dynamic> usuario) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Excluir usuário?'),
        content: Text('Deseja excluir "${usuario['nome']}"? Esta ação não pode ser desfeita.'),
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
              await context.read<AdminController>().deletarUsuario(usuario['id']);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Usuário excluído!'), backgroundColor: Color(0xFF43A047)));
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _abrirDialogCriarUsuario(BuildContext context) {
    final nomeCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final senhaCtrl = TextEditingController();
    String tipo = 'aluno';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Novo Usuário', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: ['aluno', 'professor', 'admin'].map((t) {
                      final isSelected = tipo == t;
                      final color = t == 'admin'
                          ? const Color(0xFF8E24AA)
                          : t == 'professor'
                              ? const Color(0xFF43A047)
                              : const Color(0xFF5C6BC0);
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setDialogState(() => tipo = t),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? color : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              t[0].toUpperCase() + t.substring(1),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey.shade600,
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nomeCtrl,
                    decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()),
                    validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder()),
                    validator: (v) => (v == null || !v.contains('@')) ? 'E-mail inválido' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: senhaCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Senha', border: OutlineInputBorder()),
                    validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                  ),
                ],
              ),
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
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(ctx);
                final adminCtrl = context.read<AdminController>();
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await AuthService().cadastrarCompleto(
                    email: emailCtrl.text.trim(),
                    senha: senhaCtrl.text,
                    nome: nomeCtrl.text.trim(),
                    tipo: tipo,
                  );
                  adminCtrl.carregarUsuarios();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Usuário criado!'), backgroundColor: Color(0xFF43A047)));
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Erro: $e'), backgroundColor: const Color(0xFFE53935)));
                }
              },
              child: const Text('Criar'),
            ),
          ],
        ),
      ),
    );
  }
}
