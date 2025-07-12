import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../table/todo_table.dart';
part 'todo_dao.g.dart';

@DriftAccessor(tables: [TodoItems])
class TodoDao extends DatabaseAccessor<AppDatabase> with _$TodoDaoMixin {
  TodoDao(super.db);

  Stream<List<TodoItem>> watchAllTodos({bool sortByTitle = false}) {
    try {
      final query = select(db.todoItems);
      if (sortByTitle) {
        query.orderBy([(t) => OrderingTerm(expression: t.title, mode: OrderingMode.asc)]);
      }
      return query.watch();
    } catch (e) {
      throw Exception('Failed to watch todos: $e');
    }
  }

  Future<List<TodoItem>> getNextTodos({int? lastId, int limit = 20}) async {
    try {
      final query = select(db.todoItems)
        ..orderBy([(t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc)])
        ..limit(limit);
      if (lastId != null) {
        query.where((t) => t.id.isSmallerThanValue(lastId));
      }
      return await query.get();
    } catch (e) {
      throw Exception('Failed to fetch next todos: $e');
    }
  }

  Future<List<TodoItem>> getAllTodos() async {
    try {
      return await select(db.todoItems).get();
    } catch (e) {
      throw Exception('Failed to fetch todos: $e');
    }
  }

  Future<int> insertTodo(TodoItemsCompanion todo) async {
    try {
      return await into(db.todoItems).insert(todo, mode: InsertMode.insertOrReplace);
    } catch (e) {
      throw Exception('Failed to insert todo: $e');
    }
  }

  Future<bool> updateTodo(Insertable<TodoItem> todo) async {
    try {
      return await update(db.todoItems).replace(todo);
    } catch (e) {
      throw Exception('Failed to update todo: $e');
    }
  }

  Future<int> deleteTodo(int id) async {
    try {
      return await (delete(db.todoItems)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      throw Exception('Failed to delete todo: $e');
    }
  }
}