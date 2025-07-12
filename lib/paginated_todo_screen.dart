import 'dart:async';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import '../drift/database/app_database.dart';
import '../drift/dao/todo_dao.dart';

class PaginatedTodoStreamScreen extends StatefulWidget {
  const PaginatedTodoStreamScreen({super.key});

  @override
  State<PaginatedTodoStreamScreen> createState() => PaginatedTodoStreamScreenState();
}

class PaginatedTodoStreamScreenState extends State<PaginatedTodoStreamScreen> {
  final db = AppDatabase.instance;
  late final TodoDao todoDao;
  final ScrollController scrollController = ScrollController();
  static const int pageSize = 20;
  int displayedItems = pageSize;
  bool isLoading = false;
  bool hasMore = true;
  int counter = 1;

  @override
  void initState() {
    super.initState();
    todoDao = TodoDao(db);
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 100 &&
          !isLoading &&
          hasMore) {
        loadMoreItems();
      }
    });
  }

  void loadMoreItems() async {
    if (isLoading) return;
    setState(() => isLoading = true);
    // Fetch additional items if needed (optional, for preloading)
    final totalItems = (await todoDao.getAllTodos()).length;
    setState(() {
      displayedItems += pageSize;
      hasMore = totalItems > displayedItems;
      isLoading = false;
    });
  }

  Future<void> addTodo() async {
    await todoDao.insertTodo(
      TodoItemsCompanion(
        title: Value('Todo ${counter++}'),
        description: Value('Description'),
      ),
    );
  }

  Future<void> deleteTodo(TodoItem item) async {
    await todoDao.deleteTodo(item.id);
  }

  Future<void> updateTodo(TodoItem item) async {
    await todoDao.updateTodo(
      TodoItemsCompanion(
        id: Value(item.id),
        title: Value('Updated Todo ${counter++}'),
        description: Value('Updated Description'),
      ),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paginated Stream Todos'),
      ),
      body: StreamBuilder<List<TodoItem>>(
        stream: todoDao.watchAllTodos(sortByTitle: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final todos = snapshot.data ?? [];
          if (todos.isEmpty) {
            return const Center(child: Text('No todos'));
          }
          final displayedTodos = todos.take(displayedItems).toList();
          hasMore = todos.length > displayedItems;
          return ListView.builder(
            controller: scrollController,
            itemCount: displayedTodos.length + (hasMore || isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == displayedTodos.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final item = displayedTodos[index];
              return ListTile(
                title: Text(item.title),
                subtitle: Text(item.description),
                onTap: () => deleteTodo(item),
                onLongPress: () => updateTodo(item),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addTodo,
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
  }
}