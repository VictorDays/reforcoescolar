import 'package:flutter/material.dart';
import '../services/professor_service.dart';

class ProfessorController extends ChangeNotifier {
  final ProfessorService _professorService = ProfessorService();

  List<Map<String, dynamic>> _professores = [];
  Map<String, dynamic>? _professorAtual;
  bool _isLoading = false;
  String? _erro;

  List<Map<String, dynamic>> get professores => _professores;
  Map<String, dynamic>? get professorAtual => _professorAtual;
  bool get isLoading => _isLoading;
  String? get erro => _erro;

  /// Carregar todos os professores
  Future<void> carregarProfessores() async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _professores = await _professorService.listarTodos();
    } catch (e) {
      _erro = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carregar perfil do professor logado (cria o registro se não existir)
  Future<void> carregarPerfil(String usuarioId) async {
    if (usuarioId.isEmpty) return;

    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _professorAtual = await _professorService.buscarPorUsuarioId(usuarioId);
      if (_professorAtual == null) {
        _professorAtual = await _professorService.criar(usuarioId, materias: []);
      }
    } catch (e) {
      _erro = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carregar professores por matéria
  Future<void> carregarProfessoresPorMateria(String materiaId) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _professores = await _professorService.listarPorMateria(materiaId);
    } catch (e) {
      _erro = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Atualizar perfil do professor
  Future<bool> atualizarPerfil({
    required String professorId,
    List<String>? materias,
    String? descricao,
    double? valorHora,
    String? tipoAula,
  }) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      final dados = <String, dynamic>{};
      if (materias != null) dados['materias'] = materias;
      if (descricao != null) dados['descricao'] = descricao;
      if (valorHora != null) dados['valor_hora'] = valorHora;
      if (tipoAula != null) dados['tipo_aula'] = tipoAula;

      if (dados.isNotEmpty) {
        await _professorService.atualizar(professorId, dados);
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

  /// Limpar dados
  void limpar() {
    _professores = [];
    _professorAtual = null;
    _isLoading = false;
    _erro = null;
    notifyListeners();
  }
}