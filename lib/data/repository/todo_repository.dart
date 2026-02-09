import 'package:todo/data/local/local_database.dart';
import 'package:todo/data/models/todo_model.dart';

class TodoRepository {
  LocalDatabase localDatabase = LocalDatabase.instance;

  Future<List<TodoModel>> getAllTodos() async {
    return await localDatabase.getAllTodos();
  }

  Future<bool> addTodo(TodoModel todo) async {
    return await localDatabase.addTodo(todo);
  }

  Future<bool> updateTodo(TodoModel todo) async {
    return await localDatabase.updateTodo(todo);
  }

  Future<bool> delete(int id) async {
    return await localDatabase.deleteTodo(id);
  }
}
