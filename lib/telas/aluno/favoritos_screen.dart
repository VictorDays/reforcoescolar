import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/usuario.dart';
import '../../controllers/favorito_controller.dart';
import '../../controllers/aluno_controller.dart';
import '../../widgets/professor_card.dart';
import 'professor_detalhe_screen.dart';

class FavoritosScreen extends StatefulWidget {
  final Usuario usuario;
  const FavoritosScreen({super.key, required this.usuario});
  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  String? _alunoId;

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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
        title: const Text('Favoritos', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Consumer<FavoritoController>(
        builder: (ctx, ctrl, _) {
          if (ctrl.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF5C6BC0)));
          }

          if (ctrl.favoritos.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.favorite_border_rounded, size: 72, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('Nenhum favorito ainda',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                Text('Explore professores e salve os seus favoritos!',
                    style: TextStyle(color: Colors.grey.shade400),
                    textAlign: TextAlign.center),
              ]),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFF5C6BC0),
            onRefresh: () async {
              if (_alunoId != null) {
                await ctrl.carregarFavoritos(_alunoId!);
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ctrl.favoritos.length,
              itemBuilder: (ctx, i) {
                final fav = ctrl.favoritos[i];
                final profData = fav['professores'] ?? {};
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ProfessorCard(
                    professorData: profData,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                          builder: (_) => ProfessorDetalheScreen(
                            professorData: profData,
                            usuario: widget.usuario,
                          ),
                        )),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite_rounded, color: Colors.red),
                      onPressed: () {
                        if (_alunoId != null) {
                          ctrl.toggleFavorito(_alunoId!, profData['id']);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
