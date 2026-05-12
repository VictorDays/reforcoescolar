import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/aluno_service.dart';
import '../services/professor_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final AlunoService _alunoService = AlunoService();
  final ProfessorService _professorService = ProfessorService();

  Usuario? _usuarioLogado;
  bool _isLoading = false;
  String? _erro;

  Usuario? get usuarioLogado => _usuarioLogado;
  bool get isLoading => _isLoading;
  String? get erro => _erro;
  bool get isLoggedIn => _usuarioLogado != null;

  /// Login
  Future<bool> login(String email, String senha) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _usuarioLogado = await _authService.login(email, senha);
      return _usuarioLogado != null;
    } catch (e) {
      _erro = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cadastro (apenas usuário base)
  Future<bool> cadastrar({
    required String email,
    required String senha,
    required String nome,
    required TipoUsuario tipo,
  }) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _usuarioLogado = await _authService.cadastrar(
        email: email,
        senha: senha,
        nome: nome,
        tipo: tipo,
      );
      return true;
    } catch (e) {
      _erro = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Completar cadastro de aluno (após criar usuário)
  Future<bool> completarCadastroAluno({
    required String usuarioId,
    String? serie,
    String? escola,
    List<String>? interesses,
  }) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      await _authService.completarCadastroAluno(
        usuarioId: usuarioId,
        serie: serie,
        escola: escola,
        interesses: interesses,
      );
      return true;
    } catch (e) {
      _erro = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Completar cadastro de professor
  Future<bool> completarCadastroProfessor({
    required String usuarioId,
    required List<String> materias,
    String? descricao,
    double? valorHora,
  }) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      await _authService.completarCadastroProfessor(
        usuarioId: usuarioId,
        materias: materias,
        descricao: descricao,
        valorHora: valorHora,
      );
      return true;
    } catch (e) {
      _erro = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout
  void logout() {
    _authService.logout();
    _usuarioLogado = null;
    notifyListeners();
  }

  /// Limpar erro
  void limparErro() {
    _erro = null;
    notifyListeners();
  }
}