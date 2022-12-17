import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/todo_model.dart';
import '../providers/filtered_todos.dart';
import '../providers/todo_filter.dart';

class CompletedTodos extends StatelessWidget {
  const CompletedTodos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            ShowCompletedTodos(),
            TextButton(
              onPressed: () =>
                  context.read<TodoFilter>().changefilter(Filter.completed),
              child: Text('data'),
            ),
          ],
        ),
      ),
    );
  }
}

class ShowCompletedTodos extends StatelessWidget {
  const ShowCompletedTodos({super.key});

  @override
  Widget build(BuildContext context) {
    final activeTodos = context.watch<FilteredTodos>().state.filteredTodos;
    return ListView.separated(
      primary: false,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Text(activeTodos[index].desc);
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
