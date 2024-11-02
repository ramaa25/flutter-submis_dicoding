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
      version: 2,
    onConfigure: (db) async {
      await db.execute("PRAGMA foreign_keys = ON");
    },
    onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE decision_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        resultDecision TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE decision_value_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        decision_id INTEGER,
        decisionValue TEXT,
        FOREIGN KEY (decision_id) REFERENCES decision_table (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int?> insertItem(MyModel model) async {
    final db = await database;

    // Insert into decision_table and get the generated id
    int decisionId = await db.insert('decision_table', {
      'resultDecision': model.resultDecision,
    });

    // Insert each decision value into decision_value_table with decision_id as a reference
    await db.transaction((txn) async {
      var batch = txn.batch();
      for (String value in model.decisionValue) {
        batch.insert('decision_value_table', {
          'decision_id': decisionId,
          'decisionValue': value,
        });
      }
      await batch.commit();
    });

    return decisionId;
  }

  Future<List<MyModel>> getItems() async {
  final db = await database;
  final decisionResults = await db.query('decision_table');

  List<MyModel> items = [];
  for (var decision in decisionResults) {
    final decisionId = decision['id'] as int;

    // Query decision values related to this decisionId
    final valueResults = await db.query(
      'decision_value_table',
      where: 'decision_id = ?',
      whereArgs: [decisionId],
    );

    // Extract the decisionValue list
    List<String> decisionValues = valueResults
        .map((valueMap) => valueMap['decisionValue'] as String)
        .toList();

    // Create MyModel instance and add to items list
    items.add(MyModel.fromMap(decision, decisionValues)); // Panggil fromMap dengan decisionValues
  }

  return items;
}


  Future<int> updateItem(MyModel model) async {
    final db = await database;
    return await db.update('decision_table', model.toMap(),
        where: 'id = ?', whereArgs: [model.id]);
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete('decision_table', where: 'id = ?', whereArgs: [id]);
  }
}
