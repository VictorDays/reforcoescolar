import 'package:flutter/material.dart';
import 'package:path/path.dart';
import '../models/solicitacao.dart';
import '../models/aula.dart';
import '../services/agendamento_service.dart';
import '../services/notificacao_service.dart';

class AgendamentoController extends ChangeNotifier {
  final AgendamentoService _agendamentoService = AgendamentoService();
  final NotificacaoService _notificacaoService = NotificacaoService();

  List<Solicitacao> _solicitacoes = [];
  List<Aula> _aulas = [];
  bool _isLoading = false;
  String? _erro;

  List<Solicitacao> get solicitacoes => _solicitacoes;
  List<Aula> get aulas => _aulas;
  bool get isLoading => _isLoading;
  String? get erro => _erro;
  int get quantidadeSolicitacoesPendentes => 
      _solicitacoes.where((s) => s.status == SolicitacaoStatus.pendente).length;

  /// Criar solicitação de aula (aluno)
  Future<bool> criarSolicitacao({
    required String alunoId,
    required String professorId,
    required String disciplinaId,
    String? mensagem,
    DateTime? dataSugerida,
    TimeOfDay? horarioSugerido,
  }) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      await _agendamentoService.criarSolicitacao(
        alunoId: alunoId,
        professorId: professorId,
        disciplinaId: disciplinaId,
        mensagem: mensagem,
        dataSugerida: dataSugerida,
        horarioSugerido: horarioSugerido,
      );
      
      // Recarregar solicitações do aluno
      await carregarSolicitacoesDoAluno(alunoId);
      
      return true;
    } catch (e) {
      _erro = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carregar solicitações de um professor
  Future<void> carregarSolicitacoesDoProfessor(String professorId) async {
    if (professorId.isEmpty) return;

    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _solicitacoes = await _agendamentoService.listarSolicitacoesDoProfessor(professorId);
    } catch (e) {
      _erro = e.toString();
      _solicitacoes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carregar solicitações pendentes de um professor
  Future<void> carregarSolicitacoesPendentes(String professorId) async {
    if (professorId.isEmpty) return;

    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _solicitacoes = await _agendamentoService.listarSolicitacoesPendentes(professorId);
    } catch (e) {
      _erro = e.toString();
      _solicitacoes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carregar solicitações de um aluno
  Future<void> carregarSolicitacoesDoAluno(String alunoId) async {
    if (alunoId.isEmpty) return;

    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _solicitacoes = await _agendamentoService.listarSolicitacoesDoAluno(alunoId);
    } catch (e) {
      _erro = e.toString();
      _solicitacoes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Aceitar solicitação e agendar aula
  Future<bool> aceitarSolicitacao({
    required String solicitacaoId,
    required DateTime data,
    required TimeOfDay horario,
    String? professorNome,
    String? alunoId,
    int duracao = 60,
    String? observacoes,
  }) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      final aula = await _agendamentoService.aceitarSolicitacao(
        solicitacaoId: solicitacaoId,
        data: data,
        horario: horario,
        duracao: duracao,
        observacoes: observacoes,
      );
      
      // Notificar aluno
      if (alunoId != null && professorNome != null) {
        await _notificacaoService.notificarRespostaSolicitacao(
          alunoId: alunoId,
          professorNome: professorNome,
          aceita: true,
          solicitacaoId: solicitacaoId,
        );
        
        await _notificacaoService.notificarAgendamento(
          usuarioId: alunoId,
          aulaId: aula.id,
          dataHora: '${data.day}/${data.month} às ${horario.hour.toString().padLeft(2, '0')}:${horario.minute.toString().padLeft(2, '0')}',
        );
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

  /// Recusar solicitação
  Future<bool> recusarSolicitacao({
    required String solicitacaoId,
    String? alunoId,
    String? professorNome,
  }) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      await _agendamentoService.recusarSolicitacao(solicitacaoId);
      
      // Notificar aluno
      if (alunoId != null && professorNome != null) {
        await _notificacaoService.notificarRespostaSolicitacao(
          alunoId: alunoId,
          professorNome: professorNome,
          aceita: false,
          solicitacaoId: solicitacaoId,
        );
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

  /// Carregar aulas de um professor
  Future<void> carregarAulasDoProfessor(String professorId) async {
    if (professorId.isEmpty) return;

    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _aulas = await _agendamentoService.listarAulasDoProfessor(professorId);
    } catch (e) {
      _erro = e.toString();
      _aulas = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carregar aulas de um aluno
  Future<void> carregarAulasDoAluno(String alunoId) async {
    if (alunoId.isEmpty) return;

    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _aulas = await _agendamentoService.listarAulasDoAluno(alunoId);
    } catch (e) {
      _erro = e.toString();
      _aulas = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carregar próximas aulas
  Future<void> carregarProximasAulas(String usuarioId, String tipo) async {
    if (usuarioId.isEmpty) return;

    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _aulas = await _agendamentoService.listarProximasAulas(usuarioId, tipo);
    } catch (e) {
      _erro = e.toString();
      _aulas = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cancelar aula
  Future<bool> cancelarAula(String aulaId, {String? motivo}) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      await _agendamentoService.cancelarAula(aulaId, motivo: motivo);
      return true;
    } catch (e) {
      _erro = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Concluir aula
  Future<bool> concluirAula(String aulaId) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      await _agendamentoService.concluirAula(aulaId);
      
      // Atualizar lista
      for (int i = 0; i < _aulas.length; i++) {
        if (_aulas[i].id == aulaId) {
          _aulas[i] = _aulas[i].copyWith(status: AulaStatus.concluida);
          break;
        }
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
    _solicitacoes = [];
    _aulas = [];
    _isLoading = false;
    _erro = null;
    notifyListeners();
  }
}