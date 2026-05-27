import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminController extends ChangeNotifier {
  final AdminService _adminService = AdminService();

  List<Map<String, dynamic>> _usuarios = [];
  List<Map<String, dynamic>> _professores = [];
  List<Map<String, dynamic>> _alunos = [];
  List<Map<String, dynamic>> _disciplinas = [];
  
  bool _isLoading = false;
  String? _erro;

  List<Map<String, dynamic>> get usuarios => _usuarios;
  List<Map<String, dynamic>> get professores => _professores;
  List<Map<String, dynamic>> get alunos => _alunos;
  List<Map<String, dynamic>> get disciplinas => _disciplinas;
  bool get isLoading => _isLoading;
  String? get erro => _erro;

  // ========== USUÁRIOS ==========
  Future<void> carregarUsuarios() async {
    _isLoading = true;
    notifyListeners();

    try {
      _usuarios = await _adminService.listarUsuarios();
    } catch (e) {
      _erro = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletarUsuario(String id) async {
    try {
      await _adminService.deletarUsuario(id);
      await carregarUsuarios();
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
    }
  }

  // ========== PROFESSORES ==========
  Future<void> carregarProfessores() async {
    _isLoading = true;
    notifyListeners();

    try {
      _professores = await _adminService.listarProfessores();
    } catch (e) {
      _erro = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletarProfessor(String id) async {
    try {
      await _adminService.deletarProfessor(id);
      await carregarProfessores();
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
    }
  }

  // ========== ALUNOS ==========
  Future<void> carregarAlunos() async {
    _isLoading = true;
    notifyListeners();

    try {
      _alunos = await _adminService.listarAlunos();
    } catch (e) {
      _erro = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletarAluno(String id) async {
    try {
      await _adminService.deletarAluno(id);
      await carregarAlunos();
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
    }
  }

  // ========== DISCIPLINAS ==========
  Future<void> carregarDisciplinas() async {
    _isLoading = true;
    notifyListeners();

    try {
      _disciplinas = await _adminService.listarDisciplinas();
    } catch (e) {
      _erro = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> adicionarDisciplina(String nome, String? descricao) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _adminService.criarDisciplina(nome, descricao);
      await carregarDisciplinas();
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> atualizarDisciplina(String id, String nome, String? descricao, bool ativa) async {
    try {
      await _adminService.atualizarDisciplina(id, {
        'nome': nome,
        'descricao': descricao,
        'ativa': ativa,
      });
      await carregarDisciplinas();
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
    }
  }

  Future<void> deletarDisciplina(String id) async {
    try {
      await _adminService.deletarDisciplina(id);
      await carregarDisciplinas();
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
    }
  }
}