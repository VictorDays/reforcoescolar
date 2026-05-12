import '../models/notificacao.dart';
import '../repositories/notificacao_repository.dart';

class NotificacaoService {
  final NotificacaoRepository _notificacaoRepository = NotificacaoRepository();

  /// Buscar notificações do usuário
  Future<List<Notificacao>> listarNotificacoes(String usuarioId, {bool apenasNaoLidas = false}) async {
    if (usuarioId.isEmpty) {
      throw Exception('ID do usuário obrigatório');
    }
    return await _notificacaoRepository.listarPorUsuario(usuarioId, apenasNaoLidas: apenasNaoLidas);
  }

  /// Contar notificações não lidas
  Future<int> contarNaoLidas(String usuarioId) async {
    if (usuarioId.isEmpty) return 0;
    return await _notificacaoRepository.contarNaoLidas(usuarioId);
  }

  /// Marcar notificação como lida
  Future<void> marcarComoLida(String notificacaoId) async {
    if (notificacaoId.isEmpty) {
      throw Exception('ID da notificação obrigatório');
    }
    await _notificacaoRepository.marcarComoLida(notificacaoId);
  }

  /// Marcar todas como lidas
  Future<void> marcarTodasComoLidas(String usuarioId) async {
    if (usuarioId.isEmpty) {
      throw Exception('ID do usuário obrigatório');
    }
    await _notificacaoRepository.marcarTodasComoLidas(usuarioId);
  }

  /// Deletar notificação
  Future<void> deletarNotificacao(String notificacaoId) async {
    if (notificacaoId.isEmpty) {
      throw Exception('ID da notificação obrigatório');
    }
    await _notificacaoRepository.deletar(notificacaoId);
  }

  /// Notificar professor sobre nova solicitação
  Future<void> notificarNovaSolicitacao({
    required String professorId,
    required String alunoNome,
    required String solicitacaoId,
  }) async {
    await _notificacaoRepository.notificarSolicitacao(professorId, alunoNome, solicitacaoId);
  }

  /// Notificar aluno sobre resposta da solicitação
  Future<void> notificarRespostaSolicitacao({
    required String alunoId,
    required String professorNome,
    required bool aceita,
    required String solicitacaoId,
  }) async {
    await _notificacaoRepository.notificarRespostaSolicitacao(alunoId, professorNome, aceita, solicitacaoId);
  }

  /// Notificar sobre agendamento de aula
  Future<void> notificarAgendamento({
    required String usuarioId,
    required String aulaId,
    required String dataHora,
  }) async {
    await _notificacaoRepository.notificarAgendamento(usuarioId, aulaId, dataHora);
  }

  /// Deletar todas notificações do usuário
  Future<void> deletarTodasNotificacoes(String usuarioId) async {
    if (usuarioId.isEmpty) {
      throw Exception('ID do usuário obrigatório');
    }
    await _notificacaoRepository.deletarTodas(usuarioId);
  }
}