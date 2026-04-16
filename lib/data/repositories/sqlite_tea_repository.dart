import 'package:sqflite/sqflite.dart';
import '../../domain/models/tea.dart';
import '../../domain/repositories/tea_repository.dart';
import '../database_helper.dart';

class SqliteTeaRepository implements TeaRepository {
  const SqliteTeaRepository();

  Future<Database> get _db => DatabaseHelper.instance.database;

  @override
  Future<List<Tea>> getAll() async {
    final maps = await (await _db).query('teas', orderBy: 'createdAt DESC');
    return maps.map(Tea.fromMap).toList();
  }

  @override
  Future<Tea?> getById(String id) async {
    final maps = await (await _db).query(
      'teas',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Tea.fromMap(maps.first);
  }

  @override
  Future<void> save(Tea tea) async {
    await (await _db).insert(
      'teas',
      tea.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> update(Tea tea) async {
    await (await _db).update(
      'teas',
      tea.toMap(),
      where: 'id = ?',
      whereArgs: [tea.id],
    );
  }

  @override
  Future<void> delete(String id) async {
    await (await _db).delete('teas', where: 'id = ?', whereArgs: [id]);
  }
}
