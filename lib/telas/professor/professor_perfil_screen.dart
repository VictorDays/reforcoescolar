import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/usuario.dart';
import '../../controllers/professor_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/admin_controller.dart';

class ProfessorPerfilScreen extends StatefulWidget {
  final Usuario usuario;
  const ProfessorPerfilScreen({super.key, required this.usuario});
  @override
  State<ProfessorPerfilScreen> createState() => _ProfessorPerfilScreenState();
}

class _ProfessorPerfilScreenState extends State<ProfessorPerfilScreen> {
  final _descCtrl = TextEditingController();
  final _valorCtrl = TextEditingController();
  bool _editando = false;
  String? _fotoPath;
  String _tipoAula = 'ambos';
  List<String> _materiasSelecionadas = [];
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final profCtrl = context.read<ProfessorController>();
      await profCtrl.carregarPerfil(widget.usuario.id);
      context.read<AdminController>().carregarDisciplinas();

      final prof = profCtrl.professorAtual;
      if (prof != null) {
        _descCtrl.text = prof['descricao'] ?? '';
        _valorCtrl.text = prof['valor_hora']?.toString() ?? '';
        _tipoAula = prof['tipo_aula'] ?? 'ambos';
        _materiasSelecionadas = List<String>.from(prof['materias'] ?? []);
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _valorCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final ctrl = context.read<ProfessorController>();
    final profId = ctrl.professorAtual?['id'];
    if (profId == null) return;

    final ok = await ctrl.atualizarPerfil(
      professorId: profId,
      materias: _materiasSelecionadas,
      descricao: _descCtrl.text.trim(),
      valorHora: double.tryParse(_valorCtrl.text),
      tipoAula: _tipoAula,
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
      builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
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
      ])),
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
            IconButton(icon: const Icon(Icons.edit_rounded),
                onPressed: () => setState(() => _editando = true)),
        ],
      ),
      body: Consumer<ProfessorController>(
        builder: (ctx, ctrl, _) {
          if (ctrl.isLoading) return const Center(child: CircularProgressIndicator());
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              _buildAvatar(),
              const SizedBox(height: 24),
              _buildInfoCard(),
              const SizedBox(height: 16),
              _buildProfissionalCard(),
              if (_editando) ...[
                const SizedBox(height: 16),
                _buildMateriasCard(),
              ],
              const SizedBox(height: 24),
              _buildLogoutBtn(),
            ]),
          );
        },
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(alignment: Alignment.bottomRight, children: [
      CircleAvatar(
        radius: 56,
        backgroundColor: const Color(0xFF5C6BC0).withOpacity(0.15),
        backgroundImage: _fotoPath != null ? FileImage(File(_fotoPath!)) : null,
        child: _fotoPath == null
            ? Text(
                widget.usuario.nome.isNotEmpty ? widget.usuario.nome[0].toUpperCase() : 'P',
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
    ]);
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Informações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 16),
        _staticField(Icons.person_rounded, 'Nome', widget.usuario.nome),
        const SizedBox(height: 10),
        _staticField(Icons.email_rounded, 'E-mail', widget.usuario.email),
        const SizedBox(height: 10),
        _staticField(Icons.badge_rounded, 'Tipo', widget.usuario.tipoLabel),
      ]),
    );
  }

  Widget _buildProfissionalCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Dados Profissionais', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 16),
        TextField(
          controller: _descCtrl,
          enabled: _editando,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Descrição / Bio',
            prefixIcon: const Icon(Icons.description_rounded, color: Color(0xFF5C6BC0), size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: !_editando,
            fillColor: Colors.grey.shade50,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _valorCtrl,
          enabled: _editando,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Valor por hora (R\$)',
            prefixIcon: const Icon(Icons.attach_money_rounded, color: Color(0xFF5C6BC0), size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: !_editando,
            fillColor: Colors.grey.shade50,
          ),
        ),
        if (_editando) ...[
          const SizedBox(height: 16),
          const Text('Modalidade de aula', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Row(children: [
            _tipoAulaChip('presencial', 'Presencial', Icons.location_on_rounded),
            const SizedBox(width: 8),
            _tipoAulaChip('online', 'Online', Icons.videocam_rounded),
            const SizedBox(width: 8),
            _tipoAulaChip('ambos', 'Ambos', Icons.swap_horiz_rounded),
          ]),
        ],
      ]),
    );
  }

  Widget _tipoAulaChip(String value, String label, IconData icon) {
    final isSelected = _tipoAula == value;
    return GestureDetector(
      onTap: () => setState(() => _tipoAula = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5C6BC0) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13)),
        ]),
      ),
    );
  }

  Widget _buildMateriasCard() {
    return Consumer<AdminController>(
      builder: (ctx, ctrl, _) {
        final disciplinas = ctrl.disciplinas.where((d) => d['ativa'] == true).toList();
        if (disciplinas.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Disciplinas que leciona',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: disciplinas.map((d) {
                final nome = d['nome'] as String;
                final isSelected = _materiasSelecionadas.contains(nome);
                return GestureDetector(
                  onTap: () => setState(() {
                    isSelected
                        ? _materiasSelecionadas.remove(nome)
                        : _materiasSelecionadas.add(nome);
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF5C6BC0) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF5C6BC0) : Colors.grey.shade300),
                    ),
                    child: Text(nome, style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                  ),
                );
              }).toList(),
            ),
          ]),
        );
      },
    );
  }

  Widget _staticField(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
