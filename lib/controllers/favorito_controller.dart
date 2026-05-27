import 'package:flutter/material.dart';
import '../services/favorito_service.dart';

class FavoritoController extends ChangeNotifier {
  final FavoritoService _service = FavoritoService();

  List<Map<String, dynamic>> _favoritos = [];
  Set<String> _professorIdsFavoritos = {};
  bool _isLoading = false;

  List<Map<String, dynamic>> get favoritos => _favoritos;
  bool get isLoading => _isLoading;

  bool isFavorito(String professorId) => _professorIdsFavoritos.contains(professorId);

  Future<void> carregarFavoritos(String alunoId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _favoritos = await _service.listarFavoritosDoAluno(alunoId);
      _professorIdsFavoritos = _favoritos
          .map((f) => f['professor_id'] as String)
          .toSet();
    } catch (e) {
      debugPrint('Erro ao carregar favoritos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorito(String alunoId, String professorId) async {
    try {
      if (isFavorito(professorId)) {
        await _service.remover(alunoId, professorId);
        _professorIdsFavoritos.remove(professorId);
        _favoritos.removeWhere((f) => f['professor_id'] == professorId);
      } else {
        await _service.adicionar(alunoId, professorId);
        _professorIdsFavoritos.add(professorId);
        await carregarFavoritos(alunoId);
        return;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Erro toggle favorito: $e');
    }
  }
}
