import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/usuario.dart';
import '../../controllers/professor_controller.dart';
import '../../controllers/admin_controller.dart';
import '../../widgets/professor_card.dart';
import 'professor_detalhe_screen.dart';

class ExplorarScreen extends StatefulWidget {
  final Usuario usuario;
  const ExplorarScreen({super.key, required this.usuario});
  @override
  State<ExplorarScreen> createState() => _ExplorarScreenState();
}

class _ExplorarScreenState extends State<ExplorarScreen> {
  final _searchCtrl = TextEditingController();
  String _busca = '';
  String? _materiaSelecionada;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfessorController>().carregarProfessores();
      context.read<AdminController>().carregarDisciplinas();
    });
    _searchCtrl.addListener(() => setState(() => _busca = _searchCtrl.text.toLowerCase()));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filtrar(List<Map<String, dynamic>> lista) {
    return lista.where((p) {
      final usuario = p['usuarios'] ?? {};
      final nome = (usuario['nome'] ?? '').toLowerCase();
      final materias = List<String>.from(p['materias'] ?? []);

      final passaBusca = _busca.isEmpty || nome.contains(_busca) ||
          materias.any((m) => m.toLowerCase().contains(_busca));
      final passaMateria = _materiaSelecionada == null ||
          materias.any((m) => m.toLowerCase() == _materiaSelecionada!.toLowerCase());

      return passaBusca && passaMateria;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
        title: const Text('Explorar Professores',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Buscar professor ou matéria...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF5C6BC0)),
                suffixIcon: _busca.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _busca = '');
                        })
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFiltrosMaterias(),
          Expanded(child: _buildListaProfessores()),
        ],
      ),
    );
  }

  Widget _buildFiltrosMaterias() {
    return Consumer<AdminController>(
      builder: (ctx, ctrl, _) {
        final disciplinas = ctrl.disciplinas.where((d) => d['ativa'] == true).toList();
        if (disciplinas.isEmpty) return const SizedBox.shrink();

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildFiltroChip(null, 'Todos'),
                ...disciplinas.map((d) => _buildFiltroChip(d['nome'] as String, d['nome'] as String)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFiltroChip(String? value, String label) {
    final isSelected = _materiaSelecionada == value;
    return GestureDetector(
      onTap: () => setState(() => _materiaSelecionada = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5C6BC0) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF5C6BC0) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildListaProfessores() {
    return Consumer<ProfessorController>(
      builder: (ctx, ctrl, _) {
        if (ctrl.isLoading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF5C6BC0)));
        }

        final filtrados = _filtrar(ctrl.professores);

        if (filtrados.isEmpty) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text('Nenhum professor encontrado',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
            ]),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtrados.length,
          itemBuilder: (ctx, i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ProfessorCard(
              professorData: filtrados[i],
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                    builder: (_) => ProfessorDetalheScreen(
                      professorData: filtrados[i],
                      usuario: widget.usuario,
                    ),
                  )),
            ),
          ),
        );
      },
    );
  }
}
