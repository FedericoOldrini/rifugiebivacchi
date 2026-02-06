class RifugioCheckIn {
  final String? id; // ID univoco del check-in
  final String rifugioId;
  final String rifugioNome;
  final double rifugioLat;
  final double rifugioLng;
  final double? altitudine;
  final DateTime dataVisita;
  final String? note;
  final String? fotoUrl;

  RifugioCheckIn({
    this.id,
    required this.rifugioId,
    required this.rifugioNome,
    required this.rifugioLat,
    required this.rifugioLng,
    required this.altitudine,
    required this.dataVisita,
    this.note,
    this.fotoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rifugioId': rifugioId,
      'rifugioNome': rifugioNome,
      'rifugioLat': rifugioLat,
      'rifugioLng': rifugioLng,
      'altitudine': altitudine,
      'dataVisita': dataVisita.toIso8601String(),
      'note': note,
      'fotoUrl': fotoUrl,
    };
  }

  factory RifugioCheckIn.fromMap(Map<String, dynamic> map) {
    return RifugioCheckIn(
      id: map['id'],
      rifugioId: map['rifugioId'] ?? '',
      rifugioNome: map['rifugioNome'] ?? '',
      rifugioLat: map['rifugioLat']?.toDouble() ?? 0.0,
      rifugioLng: map['rifugioLng']?.toDouble() ?? 0.0,
      altitudine: map['altitudine']?.toDouble(),
      dataVisita: DateTime.parse(map['dataVisita']),
      note: map['note'],
      fotoUrl: map['fotoUrl'],
    );
  }

  RifugioCheckIn copyWith({
    String? id,
    String? rifugioId,
    String? rifugioNome,
    double? rifugioLat,
    double? rifugioLng,
    double? altitudine,
    DateTime? dataVisita,
    String? note,
    String? fotoUrl,
  }) {
    return RifugioCheckIn(
      id: id ?? this.id,
      rifugioId: rifugioId ?? this.rifugioId,
      rifugioNome: rifugioNome ?? this.rifugioNome,
      rifugioLat: rifugioLat ?? this.rifugioLat,
      rifugioLng: rifugioLng ?? this.rifugioLng,
      altitudine: altitudine ?? this.altitudine,
      dataVisita: dataVisita ?? this.dataVisita,
      note: note ?? this.note,
      fotoUrl: fotoUrl ?? this.fotoUrl,
    );
  }
}
