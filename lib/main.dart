import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import 'drift/database/app_database.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drift Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Home(title: 'Flutter Drift'),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key, required this.title});

  final String title;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final db = AppDatabase.instance;
  int counter = 1;
  late Stream<List<TodoItem>> streamTodo;

  @override
  void initState() {
    streamTodo = db.managers.todoItems.watch();
    super.initState();
  }

  void _addTodo() async {
    await db.managers.todoItems.create(
      (o) => o(
        title: 'New Todo ${counter++}',
        description: 'New Todo Description',
      ),
    );
  }

  void _deleteTodo(TodoItem item) async {
    await db.managers.todoItems.filter((f) => f.title(item.title)).delete();
  }

  void _updateTodo(TodoItem item) async {
    await db.managers.todoItems
        .filter((f) => f.title(item.title))
        .update((o) => o(title: Value('New Todo ${counter++}')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: StreamBuilder(
        stream: streamTodo,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data?.isEmpty == true) {
            return Center(child: Text('empty'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return InkWell(
                onTap: () => _deleteTodo(item),
                onLongPress: () => _updateTodo(item),
                child: ListTile(
                  title: Text(item.title),
                  subtitle: Text(item.description),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
  }
}
