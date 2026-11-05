import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/anuncio.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();
  static const String _nomeBanco = 'anuncios.db';
  static const String _nomeTabela = 'anuncios';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final caminho = join(await getDatabasesPath(), _nomeBanco);
    _database = await openDatabase(
      caminho,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_nomeTabela (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titulo TEXT NOT NULL,
            descricao TEXT NOT NULL,
            preco REAL NOT NULL,
            imagem_path TEXT
          )
        ''');
      },
    );
    return _database!;
  }

  Future<List<Anuncio>> buscarTodos() async {
    final db = await database;
    final registros = await db.query(_nomeTabela, orderBy: 'id DESC');
    return registros.map(Anuncio.fromMap).toList();
  }

  Future<int> inserir(Anuncio anuncio) async {
    final db = await database;
    return db.insert(_nomeTabela, anuncio.toMap());
  }

  Future<int> atualizar(Anuncio anuncio) async {
    final db = await database;
    return db.update(
      _nomeTabela,
      anuncio.toMap(),
      where: 'id = ?',
      whereArgs: [anuncio.id],
    );
  }

  Future<int> excluir(int id) async {
    final db = await database;
    return db.delete(_nomeTabela, where: 'id = ?', whereArgs: [id]);
  }
}
