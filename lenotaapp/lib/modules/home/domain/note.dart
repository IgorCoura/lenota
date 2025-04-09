class Note {
  final String id;
  final String scannerFormat;
  final String data;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.scannerFormat,
    required this.data,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'scannerFormat': scannerFormat,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String toCsv() {
    return '$data;${createdAt.toIso8601String()}';
  }

  static String listToCsv(List<Note> notes) {
    return notes.map((note) => note.toCsv()).join('\n');
  }

  static Note fromMap(Map<String, Object?> map) {
    return Note(
      id: map['id'] as String,
      scannerFormat: map['scannerFormat'] as String,
      data: map['data'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  static List<Note> fromMapList(List<Map<String, Object?>> mapList) {
    return mapList.map((map) => Note.fromMap(map)).toList();
  }
}
