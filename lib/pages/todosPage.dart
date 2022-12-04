import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/pages/active_todos.dart';
import 'package:todo_app/pages/completed_todos.dart';
import 'package:todo_app/utils/debounce.dart';

import '../models/todo_model.dart';
import '../providers/active_todo_count.dart';
import '../providers/filtered_todos.dart';
import '../providers/todoList.dart';
import '../providers/todo_filter.dart';
import '../providers/todo_search.dart';

class TodosPage extends StatefulWidget {
  TodosPage({super.key});

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  List<Widget> pages = [
    AllPage(),
    ActiveTodos(),
    CompletedTodos(),
  ];
  int _pageIndex = 0;
  void _onitemTapped(int newIndex) {
    setState(() {
      _pageIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: pages.elementAt(_pageIndex),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onitemTapped,
        currentIndex: _pageIndex,
        unselectedIconTheme: IconThemeData(color: Colors.black),
        selectedIconTheme: IconThemeData(color: Colors.redAccent),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.clear_all),
            label: 'All',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.clear),
            label: 'Active',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.done_all),
            label: 'Completed',
          ),
        ],
      ),
    );
  }
}

class AllPage extends StatelessWidget {
  const AllPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            children: [
              SearchAndFilterTodo(),
              // TodoHeader(),
              // CreateTodo(),
              // SizedBox(height: height / 35),
              // SizedBox(
              //   height: 10,
              // ),
              ShowTodos(),
            ],
          ),
        ),
      ),
    );
  }
}

class TodoHeader extends StatelessWidget {
  const TodoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'TODO',
          style: TextStyle(fontSize: 40),
        ),
        Text(
          '${context.watch<ActiveTodoCount>().state.activeTodoCount} items left',
          style: TextStyle(fontSize: 20, color: Colors.redAccent),
        ),
      ],
    );
  }
}

class CreateTodo extends StatefulWidget {
  const CreateTodo({super.key});

  @override
  State<CreateTodo> createState() => _CreateTodoState();
}

class _CreateTodoState extends State<CreateTodo> {
  final newTodoController = TextEditingController();
  @override
  void dispose() {
    newTodoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: newTodoController,
      decoration: InputDecoration(
        label: Text('What to do?'),
      ),
      onSubmitted: (String todoDecs) {
        if (todoDecs != null && todoDecs.trim().isNotEmpty) {
          context.read<TodoList>().addTodo(todoDecs);
          newTodoController.clear();
        }
      },
    );
  }
}

class SearchAndFilterTodo extends StatelessWidget {
  SearchAndFilterTodo({super.key});
  final debounce = Debounce(milliseconds: 1000);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Search todos here',
            prefix: Icon(Icons.search),
            filled: true,
            border: InputBorder.none,
          ),
          onChanged: (String? newSearchTerm) {
            if (newSearchTerm != null) {
              debounce.run(() {
                context.read<TodoSearch>().searchTerm(newSearchTerm);
              });
            }
          },
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // filterButton(context, Filter.all),
            // filterButton(context, Filter.active),
            // filterButton(context, Filter.completed),
          ],
        ),
      ],
    );
  }

  Widget filterButton(BuildContext context, Filter filter) {
    return TextButton(
      onPressed: () {
        context.read<TodoFilter>().changefilter(filter);
      },
      child: Text(
        filter == Filter.all
            ? 'All'
            : filter == Filter.active
                ? 'Active'
                : 'Completed',
        style: TextStyle(
          fontSize: 18,
          color: textColor(context, filter),
        ),
      ),
    );
  }

  Color textColor(BuildContext context, Filter filter) {
    final currentFilter = context.watch<TodoFilter>().state.filter;
    return currentFilter == filter ? Colors.blue : Colors.grey;
  }
}

class ShowTodos extends StatelessWidget {
  const ShowTodos({super.key});

  Widget showDismissBack(int direction) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.red,
      alignment: direction == 0 ? Alignment.centerLeft : Alignment.centerRight,
      child: Icon(
        Icons.delete,
        size: 30,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todos = context.watch<FilteredTodos>().state.filteredTodos;
    return ListView.separated(
      primary: false,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Dismissible(
            background: showDismissBack(0),
            secondaryBackground: showDismissBack(1),
            onDismissed: (_) {
              context.read<TodoList>().removeTodo(todos[index]);
            },
            confirmDismiss: (_) {
              return showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Are you sure?'),
                      content: Text('Do you really wanna delete?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: Text('NO'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          child: Text('YES'),
                        ),
                      ],
                    );
                  });
            },
            key: ValueKey(todos[index].id),
            child: TodoItem(
              todo: todos[index],
            ));
      },
      separatorBuilder: ((context, index) {
        return Divider(
          color: Colors.grey,
        );
      }),
      itemCount: todos.length,
    );
  }
}

class TodoItem extends StatefulWidget {
  final Todo todo;
  const TodoItem({
    Key? key,
    required this.todo,
  }) : super(key: key);

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  late final TextEditingController textEditingController;
  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              bool _error = false;
              textEditingController.text = widget.todo.desc;

              return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return AlertDialog(
                  title: Text('Edit todo'),
                  content: TextField(
                    autocorrect: true,
                    controller: textEditingController,
                    decoration: InputDecoration(
                        errorText: _error ? 'Please insert something' : null),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _error =
                              textEditingController.text.isEmpty ? true : false;
                          if (!_error) {
                            context.read<TodoList>().editTodo(
                                widget.todo.id, textEditingController.text);
                            Navigator.pop(context);
                          }
                        });
                      },
                      child: Text('Edit'),
                    ),
                  ],
                );
              });
            });
      },
      leading: Checkbox(
        value: widget.todo.completed,
        onChanged: (bool? checked) {
          context.read<TodoList>().toggleTodo(widget.todo.id);
        },
      ),
      title: Text(widget.todo.desc),
    );
  }
}
