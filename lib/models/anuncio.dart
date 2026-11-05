class Anuncio {
  final int? id;
  final String titulo;
  final String descricao;
  final double preco;
  final String? imagemPath;
  final String? imagemData;

  const Anuncio({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.preco,
    this.imagemPath,
    this.imagemData,
  });

  Map<String, Object?> toMap() {
    final map = <String, Object?>{
      'titulo': titulo,
      'descricao': descricao,
      'preco': preco,
      'imagem_path': imagemPath,
      'imagem_data': imagemData,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory Anuncio.fromMap(Map<String, Object?> map) {
    return Anuncio(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String,
      preco: (map['preco'] as num).toDouble(),
      imagemPath: map['imagem_path'] as String?,
      imagemData: map['imagem_data'] as String?,
    );
  }
}
