import 'package:flutter/material.dart';
import '../models/professor.dart';
import '../models/disciplina.dart';
import '../services/professor_service.dart';

class ProfessorController extends ChangeNotifier {
  final ProfessorService _professorService = ProfessorService();

  List<Map<String, dynamic>> _professores = [];
  Map<String, dynamic>? _professorAtual;
  List<Disciplina> _disciplinasDoProfessor = [];
  bool _isLoading = false;
  String? _erro;

  List<Map<String, dynamic>> get professores => _professores;
  Map<String, dynamic>? get professorAtual => _professorAtual;
  List<Disciplina> get disciplinasDoProfessor => _disciplinasDoProfessor;
  bool get isLoading => _isLoading;
  String? get erro => _erro;

  /// Carregar todos os professores
  Future<void> carregarProfessores() async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _professores = await _professorService.listarTodosProfessores();
    } catch (e) {
      _erro = e.toString();
      _professores = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carregar professores por matéria
  Future<void> carregarProfessoresPorMateria(String disciplinaId) async {
    if (disciplinaId.isEmpty) {
      _erro = 'Selecione uma matéria';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _professores = await _professorService.buscarProfessoresPorMateria(disciplinaId);
    } catch (e) {
      _erro = e.toString();
      _professores = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carregar perfil do professor logado
  Future<void> carregarPerfilProfessor(String usuarioId) async {
    if (usuarioId.isEmpty) return;

    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      final professor = await _professorService.buscarProfessorPorUsuarioId(usuarioId);
      if (professor != null) {
        _professorAtual = {
          'professor': professor,
          'usuario': await _professorService.buscarProfessorPorId(professor.id),
        };
        
        // Carregar disciplinas que o professor ensina
        _disciplinasDoProfessor = await _professorService.obterDisciplinasDoProfessor(professor.id);
      }
    } catch (e) {
      _erro = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carregar disciplinas de um professor específico
  Future<void> carregarDisciplinasDoProfessor(String professorId) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _disciplinasDoProfessor = await _professorService.obterDisciplinasDoProfessor(professorId);
    } catch (e) {
      _erro = e.toString();
      _disciplinasDoProfessor = [];
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
      await _professorService.atualizarPerfil(
        professorId: professorId,
        materias: materias,
        descricao: descricao,
        valorHora: valorHora,
        tipoAula: tipoAula,
      );
      
      // Recarregar dados atualizados
      if (_professorAtual != null) {
        final usuarioId = _professorAtual!['usuario']['id'];
        await carregarPerfilProfessor(usuarioId);
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

  /// Limpar erro
  void limparErro() {
    _erro = null;
    notifyListeners();
  }

  /// Limpar dados
  void limpar() {
    _professores = [];
    _professorAtual = null;
    _disciplinasDoProfessor = [];
    _isLoading = false;
    _erro = null;
    notifyListeners();
  }
}