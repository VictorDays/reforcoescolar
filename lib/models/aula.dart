import 'package:flutter/material.dart';

enum AulaStatus {
  agendada,
  confirmada,
  concluida,
  cancelada,
  remarcada;

  // ✅ ADICIONE ESTES GETTERS
  String get displayName {
    switch (this) {
      case AulaStatus.agendada:
        return 'Agendada';
      case AulaStatus.confirmada:
        return 'Confirmada';
      case AulaStatus.concluida:
        return 'Concluída';
      case AulaStatus.cancelada:
        return 'Cancelada';
      case AulaStatus.remarcada:
        return 'Remarcada';
    }
  }
  
  Color get color {
    switch (this) {
      case AulaStatus.agendada:
        return Colors.orange;
      case AulaStatus.confirmada:
        return Colors.green;
      case AulaStatus.concluida:
        return Colors.blue;
      case AulaStatus.cancelada:
        return Colors.red;
      case AulaStatus.remarcada:
        return Colors.purple;
    }
  }
}


class Aula {
  final String id;
  final String solicitacaoId;
  final String professorId;
  final String alunoId;
  final String disciplinaId;
  final DateTime data;
  final TimeOfDay horario;
  final int duracao; // minutos
  final AulaStatus status;
  final String? googleEventoId;
  final String? meetLink;
  final String? observacoes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Aula({
    required this.id,
    required this.solicitacaoId,
    required this.professorId,
    required this.alunoId,
    required this.disciplinaId,
    required this.data,
    required this.horario,
    this.duracao = 60,
    required this.status,
    this.googleEventoId,
    this.meetLink,
    this.observacoes,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'solicitacao_id': solicitacaoId,
    'professor_id': professorId,
    'aluno_id': alunoId,
    'disciplina_id': disciplinaId,
    'data': data.toIso8601String(),
    'horario': '${horario.hour.toString().padLeft(2, '0')}:${horario.minute.toString().padLeft(2, '0')}',
    'duracao': duracao,
    'status': status.name,
    'google_evento_id': googleEventoId,
    'meet_link': meetLink,
    'observacoes': observacoes,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  factory Aula.fromJson(Map<String, dynamic> json) {
    final timeParts = (json['horario'] as String).split(':');
    return Aula(
      id: json['id'],
      solicitacaoId: json['solicitacao_id'],
      professorId: json['professor_id'],
      alunoId: json['aluno_id'],
      disciplinaId: json['disciplina_id'],
      data: DateTime.parse(json['data']),
      horario: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      duracao: json['duracao'] ?? 60,
      status: AulaStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AulaStatus.agendada,
      ),
      googleEventoId: json['google_evento_id'],
      meetLink: json['meet_link'],
      observacoes: json['observacoes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  /// Cópia com alterações
Aula copyWith({
  String? id,
  String? solicitacaoId,
  String? professorId,
  String? alunoId,
  String? disciplinaId,
  DateTime? data,
  TimeOfDay? horario,
  int? duracao,
  AulaStatus? status,
  String? googleEventoId,
  String? meetLink,
  String? observacoes,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return Aula(
    id: id ?? this.id,
    solicitacaoId: solicitacaoId ?? this.solicitacaoId,
    professorId: professorId ?? this.professorId,
    alunoId: alunoId ?? this.alunoId,
    disciplinaId: disciplinaId ?? this.disciplinaId,
    data: data ?? this.data,
    horario: horario ?? this.horario,
    duracao: duracao ?? this.duracao,
    status: status ?? this.status,
    googleEventoId: googleEventoId ?? this.googleEventoId,
    meetLink: meetLink ?? this.meetLink,
    observacoes: observacoes ?? this.observacoes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
/// Data formatada (ex: Hoje, Amanhã, 15/05)
  String get dataFormatada {
    final hoje = DateTime.now();
    final diff = DateTime(data.year, data.month, data.day)
        .difference(DateTime(hoje.year, hoje.month, hoje.day))
        .inDays;
    
    if (diff == 0) return 'Hoje';
    if (diff == 1) return 'Amanhã';
    return '${data.day}/${data.month}';
  }
  
  /// Horário formatado (ex: 14:30)
  String get horarioFormatado {
    return '${horario.hour.toString().padLeft(2, '0')}:${horario.minute.toString().padLeft(2, '0')}';
  }
  
  /// Data e hora completa
  DateTime get dataHoraCompleta {
    return DateTime(
      data.year,
      data.month,
      data.day,
      horario.hour,
      horario.minute,
    );
  }
  
  /// Hora de fim da aula
  DateTime get horaFim {
    return dataHoraCompleta.add(Duration(minutes: duracao));
  }

  
}