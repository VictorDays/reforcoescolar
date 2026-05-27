import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/usuario.dart';
import '../../controllers/aluno_controller.dart';
import '../../controllers/auth_controller.dart';

class AlunoPerfilScreen extends StatefulWidget {
  final Usuario usuario;
  const AlunoPerfilScreen({super.key, required this.usuario});
  @override
  State<AlunoPerfilScreen> createState() => _AlunoPerfilScreenState();
}

class _AlunoPerfilScreenState extends State<AlunoPerfilScreen> {
  final _nomeCtrl = TextEditingController();
  final _serieCtrl = TextEditingController();
  final _escolaCtrl = TextEditingController();
  bool _editando = false;
  String? _fotoPath;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nomeCtrl.text = widget.usuario.nome;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<AlunoController>().carregarPerfil(widget.usuario.id);
      final aluno = context.read<AlunoController>().alunoAtual;
      if (aluno != null) {
        _serieCtrl.text = aluno['serie'] ?? '';
        _escolaCtrl.text = aluno['escola'] ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _serieCtrl.dispose();
    _escolaCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final ctrl = context.read<AlunoController>();
    final alunoId = ctrl.alunoAtual?['id'];
    if (alunoId == null) return;

    final ok = await ctrl.atualizarPerfil(
      alunoId: alunoId,
      serie: _serieCtrl.text.trim(),
      escola: _escolaCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _editando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      ok
          ? const SnackBar(content: Text('Perfil atualizado!'), backgroundColor: Color(0xFF43A047))
          : SnackBar(content: Text(ctrl.erro ?? 'Erro ao salvar'), backgroundColor: Colors.red),
    );
  }

  Future<void> _pickFoto() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFF5C6BC0)),
            title: const Text('Câmera'),
            onTap: () async {
              Navigator.pop(ctx);
              final f = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
              if (f != null) setState(() => _fotoPath = f.path);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF5C6BC0)),
            title: const Text('Galeria'),
            onTap: () async {
              Navigator.pop(ctx);
              final f = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
              if (f != null) setState(() => _fotoPath = f.path);
            },
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
        title: const Text('Meu Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          if (_editando)
            TextButton(
              onPressed: _salvar,
              child: const Text('Salvar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => setState(() => _editando = true),
            ),
        ],
      ),
      body: Consumer<AlunoController>(
        builder: (ctx, ctrl, _) {
          if (ctrl.isLoading) return const Center(child: CircularProgressIndicator());
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildAvatar(),
                const SizedBox(height: 24),
                _buildInfoCard(ctrl),
                const SizedBox(height: 16),
                _buildAcademicCard(ctrl),
                const SizedBox(height: 24),
                _buildLogoutBtn(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 56,
          backgroundColor: const Color(0xFF5C6BC0).withOpacity(0.15),
          backgroundImage: _fotoPath != null ? FileImage(File(_fotoPath!)) : null,
          child: _fotoPath == null
              ? Text(
                  widget.usuario.nome.isNotEmpty ? widget.usuario.nome[0].toUpperCase() : 'A',
                  style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Color(0xFF5C6BC0)),
                )
              : null,
        ),
        if (_editando)
          GestureDetector(
            onTap: _pickFoto,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF5C6BC0),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard(AlunoController ctrl) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Informações Pessoais',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 16),
          _buildField(Icons.person_rounded, 'Nome', _nomeCtrl, enabled: false),
          const SizedBox(height: 12),
          _buildFieldStatic(Icons.email_rounded, 'E-mail', widget.usuario.email),
          const SizedBox(height: 12),
          _buildFieldStatic(Icons.badge_rounded, 'Tipo', widget.usuario.tipoLabel),
        ],
      ),
    );
  }

  Widget _buildAcademicCard(AlunoController ctrl) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dados Acadêmicos',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 16),
          _buildField(Icons.school_rounded, 'Série / Ano', _serieCtrl, enabled: _editando),
          const SizedBox(height: 12),
          _buildField(Icons.account_balance_rounded, 'Escola', _escolaCtrl, enabled: _editando),
        ],
      ),
    );
  }

  Widget _buildField(IconData icon, String label, TextEditingController ctrl, {bool enabled = true}) {
    return TextField(
      controller: ctrl,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF5C6BC0), size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        filled: !enabled,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildFieldStatic(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(children: [
        Icon(icon, color: const Color(0xFF5C6BC0), size: 20),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ]),
      ]),
    );
  }

  Widget _buildLogoutBtn() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          context.read<AuthController>().logout();
          Navigator.pushReplacementNamed(context, '/login');
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: const Icon(Icons.exit_to_app_rounded),
        label: const Text('Sair', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
