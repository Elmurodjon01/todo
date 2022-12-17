import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/pages/todosPage.dart';
import 'package:todo_app/providers/providers.dart';

import '../models/todo_model.dart';

class ActiveTodos extends StatelessWidget {
  const ActiveTodos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            ShowActiveTodos(),
            TextButton(
              onPressed: () =>
                  context.read<TodoFilter>().changefilter(Filter.active),
              child: Text('shiw'),
            ),
          ],
        ),
      ),
    );
  }
}

class ShowActiveTodos extends StatelessWidget {
  const ShowActiveTodos({super.key});

  @override
  Widget build(BuildContext context) {
    final activeTodos = context.watch<FilteredTodos>().state.filteredTodos;
    return ListView.separated(
      primary: false,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return TodoItem(todo: activeTodos[index]);
      },
      separatorBuilder: ((context, index) {
        return Divider(
          color: Colors.grey,
        );
      }),
      itemCount: activeTodos.length,
    );
  }
}
