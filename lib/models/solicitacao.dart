import 'package:flutter/material.dart';

enum SolicitacaoStatus {
  pendente,
  aceita,
  recusada,
  cancelada,
}

class Solicitacao {
  final String id;
  final String alunoId;
  final String professorId;
  final String disciplinaId;
  final String? mensagem;
  final SolicitacaoStatus status;
  final DateTime? dataSugerida;
  final TimeOfDay? horarioSugerido;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Solicitacao({
    required this.id,
    required this.alunoId,
    required this.professorId,
    required this.disciplinaId,
    this.mensagem,
    required this.status,
    this.dataSugerida,
    this.horarioSugerido,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'aluno_id': alunoId,
    'professor_id': professorId,
    'disciplina_id': disciplinaId,
    'mensagem': mensagem,
    'status': status.name,
    'data_sugerida': dataSugerida?.toIso8601String(),
    'horario_sugerido': horarioSugerido != null 
        ? '${horarioSugerido!.hour.toString().padLeft(2, '0')}:${horarioSugerido!.minute.toString().padLeft(2, '0')}'
        : null,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  factory Solicitacao.fromJson(Map<String, dynamic> json) {
    final timeParts = json['horario_sugerido'] != null 
        ? (json['horario_sugerido'] as String).split(':')
        : null;
    
    return Solicitacao(
      id: json['id'],
      alunoId: json['aluno_id'],
      professorId: json['professor_id'],
      disciplinaId: json['disciplina_id'],
      mensagem: json['mensagem'],
      status: SolicitacaoStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SolicitacaoStatus.pendente,
      ),
      dataSugerida: json['data_sugerida'] != null 
          ? DateTime.parse(json['data_sugerida']) 
          : null,
      horarioSugerido: timeParts != null
          ? TimeOfDay(
              hour: int.parse(timeParts[0]),
              minute: int.parse(timeParts[1]),
            )
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }
}