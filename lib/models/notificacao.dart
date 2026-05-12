enum NotificacaoTipo {
  solicitacao,
  resposta,
  agendamento,
  cancelamento,
  avaliacao,
  sistema,
}

class Notificacao {
  final String id;
  final String usuarioId;
  final String titulo;
  final String mensagem;
  final NotificacaoTipo tipo;
  final bool lida;
  final Map<String, dynamic>? dadosExtra;
  final DateTime createdAt;

  Notificacao({
    required this.id,
    required this.usuarioId,
    required this.titulo,
    required this.mensagem,
    required this.tipo,
    this.lida = false,
    this.dadosExtra,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuario_id': usuarioId,
    'titulo': titulo,
    'mensagem': mensagem,
    'tipo': tipo.name,
    'lida': lida,
    'dados_extra': dadosExtra,
    'created_at': createdAt.toIso8601String(),
  };

  factory Notificacao.fromJson(Map<String, dynamic> json) => Notificacao(
    id: json['id'],
    usuarioId: json['usuario_id'],
    titulo: json['titulo'],
    mensagem: json['mensagem'],
    tipo: NotificacaoTipo.values.firstWhere(
      (e) => e.name == json['tipo'],
    ),
    lida: json['lida'] ?? false,
    dadosExtra: json['dados_extra'],
    createdAt: DateTime.parse(json['created_at']),
  );
}