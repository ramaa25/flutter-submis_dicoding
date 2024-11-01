import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:submission_dicoding_decisioner/models/my_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database_decision.db');
    if (kDebugMode) {
      print('Database path: $path');
    }
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE decision_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        resultDecision TEXT,
        decisionValue TEXT
      )
    ''');
  }

  Future<int?> insertItem(MyModel model) async {
    final db = await database;
    List<Map<String, dynamic>> maps = model.decisionValue.map((e) => model.toMap()..['decisionValue'] = e).toList();
    if(kDebugMode) {
      print(maps);
    }

    return await db.transaction((txn) async {
      var batch = txn.batch();
      for (var map in maps) {
        batch.insert('decision_table', map);
      }
      var results = await batch.commit();
      return results.isNotEmpty ? results.last as int? : null;
    });
  }

  Future<List<MyModel>> getItems() async {
    final db = await database;
    final result = await db.query('decision_table');
    return result.map((json) => MyModel.fromMap(json)).toList();
  }

  Future<int> updateItem(MyModel model) async {
    final db = await database;
    return await db.update('decision_table', model.toMap(), where: 'id = ?', whereArgs: [model.id]);
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete('decision_table', where: 'id = ?', whereArgs: [id]);
  }
}


