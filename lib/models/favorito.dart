class Favorito {
  final int? id;
  final int usuarioId;
  final int professorId;
  final DateTime dataAdicionado;

  Favorito({
    this.id,
    required this.usuarioId,
    required this.professorId,
    required this.dataAdicionado,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'usuarioId': usuarioId,
    'professorId': professorId,
    'dataAdicionado': dataAdicionado.toIso8601String(),
  };

  factory Favorito.fromMap(Map<String, dynamic> map) => Favorito(
    id: map['id'],
    usuarioId: map['usuarioId'],
    professorId: map['professorId'],
    dataAdicionado: DateTime.parse(map['dataAdicionado']),
  );
}