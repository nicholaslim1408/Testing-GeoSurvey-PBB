import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import '../models/foto_bangunan_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('geosurvey.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if(kIsWeb) {
      var factory = databaseFactoryFfiWeb;
      return await factory.openDatabase(
        filePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _createDB,
        ),
      );
    }
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE foto_bangunan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL,
        klasifikasi TEXT NOT NULL,
        file_path TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        created_at TEXT NOT NULL,
        UNIQUE(task_id, klasifikasi) ON CONFLICT REPLACE
      )
    ''');
  }

  Future<FotoBangunanModel> create(FotoBangunanModel foto) async {
    final db = await instance.database;
    final id = await db.insert('foto_bangunan', foto.toJson());
    return foto.copyWith(id: id);
  }

  Future<List<FotoBangunanModel>> getPhotosForTask(int taskId) async {
    final db = await instance.database;
    final result = await db.query(
      'foto_bangunan',
      where: 'task_id = ?',
      whereArgs: [taskId],
    );

    return result.map((json) => FotoBangunanModel.fromJson(json)).toList();
  }

  Future<int> deletePhoto(int id) async {
    final db = await instance.database;
    return await db.delete(
      'foto_bangunan',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
