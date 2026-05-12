import 'package:flutter/material.dart';
import '../models/disciplina.dart';
import '../services/professor_service.dart';

class DisciplinaController extends ChangeNotifier {
  final ProfessorService _professorService = ProfessorService();

  List<Disciplina> _disciplinas = [];
  bool _isLoading = false;
  String? _erro;

  List<Disciplina> get disciplinas => _disciplinas;
  bool get isLoading => _isLoading;
  String? get erro => _erro;
  bool get hasDisciplinas => _disciplinas.isNotEmpty;

  /// Carregar todas as disciplinas
  Future<void> carregarDisciplinas({bool apenasAtivas = true}) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      // TODO: Adicionar método listarDisciplinas no service
      // _disciplinas = await _disciplinaService.listarTodas(apenasAtivas: apenasAtivas);
      
      // Por enquanto simulando dados
      _disciplinas = [
        Disciplina(
          id: '1',
          nome: 'Matemática',
          descricao: 'Álgebra, Geometria, Cálculo',
          icone: 'calculate',
          cor: '#2196F3',
          createdAt: DateTime.now(),
        ),
        Disciplina(
          id: '2',
          nome: 'Português',
          descricao: 'Gramática, Redação, Literatura',
          icone: 'menu_book',
          cor: '#4CAF50',
          createdAt: DateTime.now(),
        ),
        Disciplina(
          id: '3',
          nome: 'Ciências',
          descricao: 'Biologia, Física, Química',
          icone: 'science',
          cor: '#9C27B0',
          createdAt: DateTime.now(),
        ),
      ];
    } catch (e) {
      _erro = e.toString();
      _disciplinas = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Buscar disciplina por ID
  Disciplina? buscarPorId(String id) {
    try {
      return _disciplinas.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Buscar disciplinas por lista de IDs
  List<Disciplina> buscarPorIds(List<String> ids) {
    return _disciplinas.where((d) => ids.contains(d.id)).toList();
  }

  /// Limpar erro
  void limparErro() {
    _erro = null;
    notifyListeners();
  }
}