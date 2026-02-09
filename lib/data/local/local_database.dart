import 'dart:developer';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/Utils/app_exceptions.dart';
import 'package:todo/data/models/todo_model.dart';

class LocalDatabase {
  Database? db;
  static String tableName = 'todo';

  LocalDatabase._();

  static final LocalDatabase instance = LocalDatabase._();

  Future<Database> getDb() async {
    if (db != null) {
      return db!;
    }
    return initDb();
  }

  Future<List<TodoModel>> getAllTodos() async {
    final dbRef = await getDb();
    try {
      // Change your query to sort by ID descending automatically
      final List<Map<String, dynamic>> maps = await dbRef.query(
        'todo',
        orderBy: 'id DESC',
      );
      ;
      return List.generate(maps.length, (i) {
        return TodoModel.fromMap(maps[i]);
      });
    } on DatabaseException catch (e) {
      throw dbExceptions("SQL Syntax Error", e.toString());
    } catch (e) {
      throw dbExceptions("Unknown error occurred", e.toString());
    }
  }

  Future<bool> addTodo(TodoModel todo) async {
    try {
      final dbRef = await getDb();
      int isAdded = await dbRef.insert('todo', todo.toMap());
      return isAdded > 0 ? true : false;
    } on DatabaseException catch (e) {
      throw dbExceptions("Database Exception", e.toString());
    } catch (e) {
      throw dbExceptions("Unknown error occurred", e.toString());
    }
  }

  Future<bool> deleteTodo(int id) async {
    try {
      final dbRef = await getDb();
      int isDeleted = await dbRef.delete(
        'todo',
        where: 'id=?',
        whereArgs: [id],
      );
      return isDeleted > 0 ? true : false;
    } on DatabaseException catch (e) {
      throw dbExceptions("Database Exception", e.toString());
    } catch (e) {
      throw dbExceptions("Unknown error occurred", e.toString());
    }
  }

  Future<bool> updateTodo(TodoModel todo) async {
    if (todo.id == null) {
      log("Todo id Null");
    }
    try {
      final dbRef = await getDb();
      int isUpdated = await dbRef.update(
        'todo',
        todo.toMap(),
        where: 'id=?',
        whereArgs: [todo.id],
      );
      return isUpdated > 0 ? true : false;
    } on DatabaseException catch (e) {
      throw dbExceptions("Database Exception", e.toString());
    } catch (e) {
      throw dbExceptions("Unknown error occurred", e.toString());
    }
  }

  Future<Database> initDb() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDir.path, "appdb.db");
    db = await openDatabase(
      dbPath,
      onCreate: (db, version) async {
        await db.execute('''
           CREATE TABLE todo (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    task TEXT,
    timeline TEXT,
    desc TEXT,
    isDone INTEGER
  )
          ''');
      },
      version: 1,
    );
    return db!;
  }
}
