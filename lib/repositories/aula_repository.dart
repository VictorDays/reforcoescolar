import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/aula.dart';
import 'base_repository.dart';

class AulaRepository extends BaseRepository {
  
  /// Criar nova aula
  Future<Aula> criar(Aula aula) async {
    try {
      final data = aula.toJson();
      data.remove('id');
      
      final response = await supabase
          .from('aulas')
          .insert(data)
          .select()
          .single();
      
      logSuccess('criar');
      return Aula.fromJson(response);
    } catch (e) {
      logError('criar', e);
      rethrow;
    }
  }
  
  /// Buscar aula por ID
  Future<Aula?> buscarPorId(String id) async {
    try {
      // ✅ CORRIGIDO: select() primeiro, depois eq()
      final response = await supabase
          .from('aulas')
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) return null;
      
      return Aula.fromJson(response);
    } catch (e) {
      logError('buscarPorId', e);
      return null;
    }
  }
  
  /// Listar aulas de um professor
  Future<List<Aula>> listarPorProfessor(String professorId, {AulaStatus? status}) async {
    try {
      // ✅ CORRIGIDO: select() primeiro, depois filters
      var query = supabase
          .from('aulas')
          .select()
          .eq('professor_id', professorId);
      
      if (status != null) {
        query = query.eq('status', status.name);
      }
      
      final response = await query
          .order('data', ascending: true)
          .order('horario', ascending: true);
      
      return response.map((json) => Aula.fromJson(json)).toList();
    } catch (e) {
      logError('listarPorProfessor', e);
      return [];
    }
  }
  
  /// Listar aulas de um aluno
  Future<List<Aula>> listarPorAluno(String alunoId, {AulaStatus? status}) async {
    try {
      // ✅ CORRIGIDO: select() primeiro, depois filters
      var query = supabase
          .from('aulas')
          .select()
          .eq('aluno_id', alunoId);
      
      if (status != null) {
        query = query.eq('status', status.name);
      }
      
      final response = await query
          .order('data', ascending: true)
          .order('horario', ascending: true);
      
      return response.map((json) => Aula.fromJson(json)).toList();
    } catch (e) {
      logError('listarPorAluno', e);
      return [];
    }
  }
  
  /// Listar próximas aulas (a partir de hoje)
  Future<List<Aula>> listarProximas(String usuarioId, String tipo) async {
    try {
      final hoje = DateTime.now().toIso8601String().split('T')[0];
      final campoId = tipo == 'professor' ? 'professor_id' : 'aluno_id';
      
      // ✅ CORRIGIDO: select() primeiro, depois filters
      final response = await supabase
          .from('aulas')
          .select()
          .eq(campoId, usuarioId)
          .gte('data', hoje)
          .neq('status', 'cancelada')
          .order('data', ascending: true)
          .order('horario', ascending: true);
      
      return response.map((json) => Aula.fromJson(json)).toList();
    } catch (e) {
      logError('listarProximas', e);
      return [];
    }
  }
  
  /// Atualizar status da aula
  Future<void> atualizarStatus(String aulaId, AulaStatus novoStatus) async {
    try {
      await supabase
          .from('aulas')
          .update({
            'status': novoStatus.name,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', aulaId);
      
      logSuccess('atualizarStatus');
    } catch (e) {
      logError('atualizarStatus', e);
      rethrow;
    }
  }
  
  /// Cancelar aula
  Future<void> cancelar(String aulaId, {String? motivo}) async {
    try {
      await supabase
          .from('aulas')
          .update({
            'status': AulaStatus.cancelada.name,
            'observacoes': motivo,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', aulaId);
      
      logSuccess('cancelar');
    } catch (e) {
      logError('cancelar', e);
      rethrow;
    }
  }
  
  /// Concluir aula
  Future<void> concluir(String aulaId) async {
    await atualizarStatus(aulaId, AulaStatus.concluida);
  }
  
  /// Salvar Google Evento ID
  Future<void> salvarGoogleEventoId(String aulaId, String googleEventoId) async {
    try {
      await supabase
          .from('aulas')
          .update({
            'google_evento_id': googleEventoId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', aulaId);
      
      logSuccess('salvarGoogleEventoId');
    } catch (e) {
      logError('salvarGoogleEventoId', e);
      rethrow;
    }
  }
  
  /// Salvar Meet link
  Future<void> salvarMeetLink(String aulaId, String meetLink) async {
    try {
      await supabase
          .from('aulas')
          .update({
            'meet_link': meetLink,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', aulaId);
      
      logSuccess('salvarMeetLink');
    } catch (e) {
      logError('salvarMeetLink', e);
      rethrow;
    }
  }
  
  /// Verificar conflito de horário
  Future<bool> verificarConflito(String professorId, DateTime data, TimeOfDay horario, int duracao) async {
    try {
      final dataStr = data.toIso8601String().split('T')[0];
      
      // ✅ CORRIGIDO: select() primeiro, depois filters
      final aulas = await supabase
          .from('aulas')
          .select()
          .eq('professor_id', professorId)
          .eq('data', dataStr)
          .neq('status', 'cancelada');
      
      final inicioMinutos = horario.hour * 60 + horario.minute;
      final fimMinutos = inicioMinutos + duracao;
      
      for (var aula in aulas) {
        final aulaHorario = aula['horario'] as String;
        final aulaDuracao = aula['duracao'] as int? ?? 60;
        
        final aulaParts = aulaHorario.split(':');
        final aulaInicioMinutos = int.parse(aulaParts[0]) * 60 + int.parse(aulaParts[1]);
        final aulaFimMinutos = aulaInicioMinutos + aulaDuracao;
        
        // Verificar sobreposição
        if (inicioMinutos < aulaFimMinutos && fimMinutos > aulaInicioMinutos) {
          return true; // Tem conflito
        }
      }
      
      return false; // Sem conflito
    } catch (e) {
      logError('verificarConflito', e);
      return true;
    }
  }
}