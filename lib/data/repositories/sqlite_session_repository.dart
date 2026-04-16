import 'package:sqflite/sqflite.dart';
import '../../domain/models/session.dart';
import '../../domain/repositories/session_repository.dart';
import '../database_helper.dart';

class SqliteSessionRepository implements SessionRepository {
  const SqliteSessionRepository();

  Future<Database> get _db => DatabaseHelper.instance.database;

  @override
  Future<List<Session>> getAll() async {
    final maps = await (await _db).query('sessions', orderBy: 'dateTime DESC');
    return maps.map(Session.fromMap).toList();
  }

  @override
  Future<void> save(Session session) async {
    await (await _db).insert(
      'sessions',
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> update(Session session) async {
    await (await _db).update(
      'sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  @override
  Future<void> delete(String id) async {
    await (await _db).delete('sessions', where: 'id = ?', whereArgs: [id]);
  }
}
