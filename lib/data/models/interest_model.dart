class Interest {
  final String emoji;
  final String nombre;
  final String category;

  Interest({required this.emoji, required this.nombre, required this.category});

  factory Interest.fromJson(Map<String, dynamic> json, String category) {
    return Interest(
      emoji: json['emoji'] as String,
      nombre: json['nombre'] as String,
      category: category,
    );
  }

  String get displayName => '$emoji $nombre';

  @override
  String toString() => displayName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Interest &&
          runtimeType == other.runtimeType &&
          nombre == other.nombre;

  @override
  int get hashCode => nombre.hashCode;
}
