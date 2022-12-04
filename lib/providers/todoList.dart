import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:todo_app/models/todo_model.dart';

class TodoListState extends Equatable {
  final List<Todo> todos;
  TodoListState({
    required this.todos,
  });

  factory TodoListState.initial() {
    return TodoListState(todos: [
      Todo(desc: 'do the dishes', id: '1'),
      Todo(desc: 'Assignment due today', id: '2'),
      Todo(desc: 'bring notes to prof', id: '32'),
    ]);
  }
  @override
  List<Object?> get props => [todos];

  @override
  bool get stringify => true;

  TodoListState copyWith({
    List<Todo>? todos,
  }) {
    return TodoListState(
      todos: todos ?? this.todos,
    );
  }
}

class TodoList with ChangeNotifier {
  TodoListState _state = TodoListState.initial();
  TodoListState get state => _state;

  void addTodo(String todoDesc) {
    final newTodo = Todo(desc: todoDesc);
    final newTodos = [..._state.todos, newTodo];
    _state = _state.copyWith(todos: newTodos);
    notifyListeners();
  }

  void editTodo(String id, String todoDesc) {
    final newTodos = _state.todos.map((Todo todo) {
      if (todo.id == id) {
        return Todo(
          desc: todoDesc,
          id: id,
          completed: todo.completed,
        );
      }
      return todo;
    }).toList();
    _state = _state.copyWith(todos: newTodos);
    notifyListeners();
  }

  void toggleTodo(String id) {
    final newTodos = _state.todos.map((Todo todo) {
      if (todo.id == id) {
        return Todo(desc: todo.desc, id: id, completed: !todo.completed);
      }
      return todo;
    }).toList();
    _state = _state.copyWith(todos: newTodos);
    notifyListeners();
  }

  void removeTodo(Todo todo) {
    final newTodos = _state.todos.where((Todo t) => t.id != todo.id).toList();
    _state = _state.copyWith(todos: newTodos);
    notifyListeners();
  }
}
