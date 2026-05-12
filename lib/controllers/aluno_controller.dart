import 'package:flutter/material.dart';
import '../models/aluno.dart';
import '../models/professor.dart';
import '../services/aluno_service.dart';
import '../services/favorito_service.dart';

class AlunoController extends ChangeNotifier {
  final AlunoService _alunoService = AlunoService();
  final FavoritoService _favoritoService = FavoritoService();

  Aluno? _alunoAtual;
  List<Map<String, dynamic>> _favoritos = [];
  bool _isLoading = false;
  String? _erro;
  bool _isFavorito = false;

  Aluno? get alunoAtual => _alunoAtual;
  List<Map<String, dynamic>> get favoritos => _favoritos;
  bool get isLoading => _isLoading;
  String? get erro => _erro;
  bool get isFavorito => _isFavorito;
  int get totalFavoritos => _favoritos.length;

  /// Carregar perfil do aluno logado
  Future<void> carregarPerfilAluno(String usuarioId) async {
    if (usuarioId.isEmpty) return;

    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      final aluno = await _alunoService.buscarAlunoPorUsuarioId(usuarioId);
      if (aluno != null) {
        _alunoAtual = aluno;
        
        // Carregar favoritos do aluno
        await carregarFavoritos(aluno.id);
      }
    } catch (e) {
      _erro = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carregar favoritos do aluno
  Future<void> carregarFavoritos(String alunoId) async {
    if (alunoId.isEmpty) return;

    try {
      _favoritos = await _alunoService.listarProfessoresFavoritos(alunoId);
    } catch (e) {
      _erro = e.toString();
      _favoritos = [];
    }
    notifyListeners();
  }

  /// Verificar se professor é favorito
  Future<void> verificarFavorito(String alunoId, String professorId) async {
    if (alunoId.isEmpty || professorId.isEmpty) return;

    try {
      _isFavorito = await _alunoService.isProfessorFavorito(alunoId, professorId);
    } catch (e) {
      _isFavorito = false;
    }
    notifyListeners();
  }

  /// Adicionar professor aos favoritos
  Future<bool> favoritarProfessor(String alunoId, String professorId) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      await _alunoService.favoritarProfessor(alunoId, professorId);
      _isFavorito = true;
      
      // Recarregar lista de favoritos
      await carregarFavoritos(alunoId);
      
      return true;
    } catch (e) {
      _erro = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Remover professor dos favoritos
  Future<bool> desfavoritarProfessor(String alunoId, String professorId) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      await _alunoService.desfavoritarProfessor(alunoId, professorId);
      _isFavorito = false;
      
      // Recarregar lista de favoritos
      await carregarFavoritos(alunoId);
      
      return true;
    } catch (e) {
      _erro = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Alternar favorito (adicionar/remover)
  Future<bool> toggleFavorito(String alunoId, String professorId) async {
    if (_isFavorito) {
      return await desfavoritarProfessor(alunoId, professorId);
    } else {
      return await favoritarProfessor(alunoId, professorId);
    }
  }

  /// Atualizar perfil do aluno
  Future<bool> atualizarPerfil({
    String? serie,
    String? escola,
    List<String>? interesses,
  }) async {
    if (_alunoAtual == null) {
      _erro = 'Aluno não encontrado';
      return false;
    }

    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      await _alunoService.atualizarPerfil(
        alunoId: _alunoAtual!.id,
        serie: serie,
        escola: escola,
        interesses: interesses,
      );
      
      // Recarregar dados atualizados
      if (_alunoAtual?.usuarioId != null) {
        await carregarPerfilAluno(_alunoAtual!.usuarioId);
      }
      
      return true;
    } catch (e) {
      _erro = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Buscar aluno completo (com dados do usuário)
  Future<Map<String, dynamic>?> buscarAlunoCompleto(String usuarioId) async {
    if (usuarioId.isEmpty) return null;
    
    try {
      return await _alunoService.buscarAlunoCompleto(usuarioId);
    } catch (e) {
      _erro = e.toString();
      return null;
    }
  }

  /// Limpar erro
  void limparErro() {
    _erro = null;
    notifyListeners();
  }

  /// Limpar dados
  void limpar() {
    _alunoAtual = null;
    _favoritos = [];
    _isLoading = false;
    _erro = null;
    _isFavorito = false;
    notifyListeners();
  }
}