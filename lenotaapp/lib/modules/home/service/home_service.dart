import 'package:lenotaapp/db.dart';
import 'package:lenotaapp/modules/home/domain/note.dart';
import 'package:lenotaapp/modules/home/exceptions/duplicate_exception.dart';

class HomeService {
  Future addScanner(Note note) async {
    var db = await DB.instance.database;
    var existingNotes = await db.database.query(
      'notes',
      where: 'data = ?',
      whereArgs: [note.data],
    );

    if (existingNotes.isNotEmpty) {
      throw DuplicateException();
    }

    await db.database.insert('notes', note.toMap());
  }

  Future<List<Note>> getScanners(int limit, int offset) async {
    var db = await DB.instance.database;
    var list = await db.database.query('notes', limit: 10, offset: 0);
    return Note.fromMapList(list);
  }

  Future<List<Note>> getAllScanners() async {
    var db = await DB.instance.database;
    var list = await db.database.query('notes');
    return Note.fromMapList(list);
  }

  Future<List<Note>> getScannersByDateRange(
      DateTime startDate, DateTime endDate) async {
    var db = await DB.instance.database;
    var list = await db.database.query(
      'notes',
      where: 'createdAt >= ? AND createdAt <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
    );
    return Note.fromMapList(list);
  }

  Future removeScannerById(String id) async {
    var db = await DB.instance.database;
    await db.database.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
