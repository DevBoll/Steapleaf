import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  static DatabaseHelper get instance => _instance;
  DatabaseHelper._();

  Database? _db;
  Completer<Database>? _openCompleter;

  Future<Database> get database async {
    if (_db != null) return _db!;
    if (_openCompleter != null) return _openCompleter!.future;
    _openCompleter = Completer<Database>();
    try {
      _db = await _initDb();
      _openCompleter!.complete(_db!);
    } catch (e) {
      _openCompleter!.completeError(e);
      _openCompleter = null;
      rethrow;
    }
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'steapleaf.db');
    return openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE teas (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            origin TEXT,
            vendor TEXT,
            inStock INTEGER NOT NULL DEFAULT 1,
            photoTeaPath TEXT,
            photoLabelPath TEXT,
            notes TEXT,
            rating INTEGER NOT NULL DEFAULT 0,
            isFavorite INTEGER NOT NULL DEFAULT 0,
            tags TEXT NOT NULL DEFAULT '[]',
            flavorProfile TEXT,
            brewVariants TEXT NOT NULL DEFAULT '[]',
            defaultVariantId TEXT,
            createdAt TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE sessions (
            id TEXT PRIMARY KEY,
            dateTime TEXT NOT NULL,
            teaId TEXT,
            teaName TEXT NOT NULL,
            teaType TEXT NOT NULL,
            brewVariant TEXT,
            infusionLogs TEXT NOT NULL DEFAULT '[]',
            additions TEXT NOT NULL DEFAULT '[]',
            notes TEXT,
            rating INTEGER NOT NULL DEFAULT 0,
            isManual INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  // Export / Import (tabellenübergreifend)

  Future<Map<String, dynamic>> exportAll() async {
    final db = await database;
    final teas = await db.query('teas');
    final sessions = await db.query('sessions');
    return {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'teas': teas,
      'sessions': sessions,
    };
  }

  Future<void> importAll(Map<String, dynamic> data) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('teas');
      await txn.delete('sessions');
      for (final t in (data['teas'] as List? ?? [])) {
        await txn.insert('teas', Map<String, dynamic>.from(t as Map));
      }
      for (final s in (data['sessions'] as List? ?? [])) {
        await txn.insert('sessions', Map<String, dynamic>.from(s as Map));
      }
    });
  }
}
