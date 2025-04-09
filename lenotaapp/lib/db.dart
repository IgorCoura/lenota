import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DB {
  static final DB instance = DB._();
  static Database? _database;

  DB._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'lenotaapp.db'),
      onCreate: _onCreate,
      version: 1,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(_notes);
  }

  String get _notes => '''
      CREATE TABLE notes(
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        scannerFormat TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''';
}
