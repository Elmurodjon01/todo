import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/pages/todosPage.dart';
import 'package:todo_app/providers/active_todo_count.dart';
import 'package:todo_app/providers/filtered_todos.dart';
import 'package:todo_app/providers/todoList.dart';
import 'package:todo_app/providers/todo_filter.dart';
import 'package:todo_app/providers/todo_search.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TodoFilter>(create: (context) => TodoFilter()),
        ChangeNotifierProvider<TodoSearch>(create: (context) => TodoSearch()),
        ChangeNotifierProvider<TodoList>(create: (context) => TodoList()),
        ChangeNotifierProxyProvider<TodoList, ActiveTodoCount>(
          create: (context) => ActiveTodoCount(
              initialActiveTodoCount:
                  context.read<TodoList>().state.todos.length),
          update:
              (context, TodoList todoList, ActiveTodoCount? activeTodoCount) =>
                  activeTodoCount!..updateTodos(todoList),
        ),
        ChangeNotifierProxyProvider3(
            create: (context) => FilteredTodos(),
            update: (
              context,
              TodoFilter todoFilter,
              TodoSearch todoSearch,
              TodoList todoList,
              FilteredTodos? filteredTodos,
            ) =>
                filteredTodos!..update(todoFilter, todoSearch, todoList))
      ],
      child: MaterialApp(
        title: 'TODOS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: TodosPage(),
      ),
    );
  }
}
