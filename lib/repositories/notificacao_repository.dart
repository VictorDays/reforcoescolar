import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notificacao.dart';
import 'base_repository.dart';

class NotificacaoRepository extends BaseRepository {
  
  /// Criar notificação
  Future<Notificacao> criar(Notificacao notificacao) async {
    try {
      final data = notificacao.toJson();
      data.remove('id');
      
      final response = await supabase
          .from('notificacoes')
          .insert(data)
          .select()
          .single();
      
      logSuccess('criar');
      return Notificacao.fromJson(response);
    } catch (e) {
      logError('criar', e);
      rethrow;
    }
  }
  
  /// Buscar notificações de um usuário
  Future<List<Notificacao>> listarPorUsuario(String usuarioId, {bool apenasNaoLidas = false}) async {
    try {
      var query = supabase
          .from('notificacoes')
          .select()
          .eq('usuario_id', usuarioId)
          .order('created_at', ascending: false);
      
      if (apenasNaoLidas) {
        query = query.eq('lida', false);
      }
      
      final response = await query;
      return response.map((json) => Notificacao.fromJson(json)).toList();
    } catch (e) {
      logError('listarPorUsuario', e);
      return [];
    }
  }
  
  /// Contar notificações não lidas
  Future<int> contarNaoLidas(String usuarioId) async {
    try {
      final response = await supabase
          .from('notificacoes')
          .select('id', count: CountOption.exact)
          .eq('usuario_id', usuarioId)
          .eq('lida', false);
      
      return response.count ?? 0;
    } catch (e) {
      logError('contarNaoLidas', e);
      return 0;
    }
  }
  
  /// Marcar notificação como lida
  Future<void> marcarComoLida(String notificacaoId) async {
    try {
      await supabase
          .from('notificacoes')
          .update({'lida': true})
          .eq('id', notificacaoId);
      
      logSuccess('marcarComoLida');
    } catch (e) {
      logError('marcarComoLida', e);
      rethrow;
    }
  }
  
  /// Marcar todas como lidas
  Future<void> marcarTodasComoLidas(String usuarioId) async {
    try {
      await supabase
          .from('notificacoes')
          .update({'lida': true})
          .eq('usuario_id', usuarioId)
          .eq('lida', false);
      
      logSuccess('marcarTodasComoLidas');
    } catch (e) {
      logError('marcarTodasComoLidas', e);
      rethrow;
    }
  }
  
  /// Deletar notificação
  Future<void> deletar(String notificacaoId) async {
    try {
      await supabase
          .from('notificacoes')
          .delete()
          .eq('id', notificacaoId);
      
      logSuccess('deletar');
    } catch (e) {
      logError('deletar', e);
      rethrow;
    }
  }
  
  /// Deletar todas as notificações de um usuário
  Future<void> deletarTodas(String usuarioId) async {
    try {
      await supabase
          .from('notificacoes')
          .delete()
          .eq('usuario_id', usuarioId);
      
      logSuccess('deletarTodas');
    } catch (e) {
      logError('deletarTodas', e);
      rethrow;
    }
  }
  
  /// Criar notificação de solicitação de aula
  Future<void> notificarSolicitacao(String professorId, String alunoNome, String solicitacaoId) async {
    final notificacao = Notificacao(
      id: '',
      usuarioId: professorId,
      titulo: 'Nova solicitação de aula',
      mensagem: '$alunoNome enviou uma solicitação de aula',
      tipo: NotificacaoTipo.solicitacao,
      dadosExtra: {'solicitacao_id': solicitacaoId},
      createdAt: DateTime.now(),
    );
    
    await criar(notificacao);
  }
  
  /// Criar notificação de resposta da solicitação
  Future<void> notificarRespostaSolicitacao(String alunoId, String professorNome, bool aceita, String solicitacaoId) async {
    final titulo = aceita ? 'Solicitação aceita!' : 'Solicitação recusada';
    final mensagem = aceita 
        ? '$professorNome aceitou sua solicitação. Agende o horário!'
        : '$professorNome recusou sua solicitação.';
    
    final notificacao = Notificacao(
      id: '',
      usuarioId: alunoId,
      titulo: titulo,
      mensagem: mensagem,
      tipo: NotificacaoTipo.resposta,
      dadosExtra: {'solicitacao_id': solicitacaoId},
      createdAt: DateTime.now(),
    );
    
    await criar(notificacao);
  }
  
  /// Criar notificação de agendamento
  Future<void> notificarAgendamento(String usuarioId, String aulaId, String dataHora) async {
    final notificacao = Notificacao(
      id: '',
      usuarioId: usuarioId,
      titulo: 'Aula agendada',
      mensagem: 'Sua aula foi agendada para $dataHora',
      tipo: NotificacaoTipo.agendamento,
      dadosExtra: {'aula_id': aulaId},
      createdAt: DateTime.now(),
    );
    
    await criar(notificacao);
  }
}