
import 'package:flutter/material.dart';
import 'package:reforcoescolar/telas/login_screen.dart';
import '../database/db_helper.dart';
import '../modelos/usuario.dart';
import '../modelos/professor.dart';
import '../widgets/professor_card.dart';

class FavoritosScreen extends StatefulWidget {
  final Usuario usuario;

  const FavoritosScreen({super.key, required this.usuario});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  List<Professor> _favoritos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarFavoritos();
  }

  Future<void> _carregarFavoritos() async {
    setState(() => _isLoading = true);
    final favoritos = await DBHelper.getFavoritosByUsuario(widget.usuario.id!);
    setState(() {
      _favoritos = favoritos;
      _isLoading = false;
    });
  }

  Future<void> _removerFavorito(Professor professor) async {
    await DBHelper.removeFavorito(widget.usuario.id!, professor.id!);
    _carregarFavoritos();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${professor.nome} removido dos favoritos')),
    );
  }

  Future<void> _logout() async {
    await DBHelper.logout(widget.usuario.id!);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Favoritos'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Botão de logout para todos os usuários
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoritos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum professor favorito',
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toque no coração para favoritar um professor',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _favoritos.length,
                  itemBuilder: (context, index) {
                    return ProfessorCard(
                      professor: _favoritos[index],
                      isFavorito: true,
                      onFavoritoTap: () => _removerFavorito(_favoritos[index]),
                      onTap: () {
                        // Mostrar detalhes
                      },
                    );
                  },
                ),
    );
  }
}