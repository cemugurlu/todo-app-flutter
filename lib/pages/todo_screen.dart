import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plantist/controllers/todo_controller.dart';
import 'package:plantist/models/todo_model.dart';
import 'package:plantist/pages/add_todo_sheet_screen.dart';
import 'package:plantist/todo_search_delegate.dart';
import 'package:plantist/widgets/todo_section.dart';

class TodoScreen extends StatelessWidget {
  final TodoController todoController = Get.put(TodoController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Plantist',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: TodoSearchDelegate(todoController.todos),
              );
            },
          ),
        ],
      ),
      body: Obx(
        () {
          final todayTodos = _sortTodos(todoController.todayTodos);
          final tomorrowTodos = _sortTodos(todoController.tomorrowTodos);
          final thisWeekTodos = _sortTodos(todoController.thisWeekTodos);
          final moreThanOneWeekTodos = _sortTodos(todoController.moreThanOneWeekTodos);
          final notDatedTodos = todoController.notDatedTodos;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TodoSection(
                  title: 'Today',
                  todos: todayTodos,
                  todoController: todoController,
                ),
                const Divider(),
                TodoSection(
                  title: 'Tomorrow',
                  todos: tomorrowTodos,
                  todoController: todoController,
                ),
                const Divider(),
                TodoSection(
                  title: 'This Week',
                  todos: thisWeekTodos,
                  todoController: todoController,
                ),
                const Divider(),
                TodoSection(
                  title: 'More Than One Week',
                  todos: moreThanOneWeekTodos,
                  todoController: todoController,
                ),
                const Divider(),
                TodoSection(
                  title: 'Not Dated',
                  todos: notDatedTodos,
                  todoController: todoController,
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: () {
              _showAddTodoBottomSheet(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(13, 22, 40, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
            ),
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            label: const Text(
              'New Reminder',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  List<Todo> _sortTodos(List<Todo> todos) {
    return [...todos]..sort((a, b) => a.selectedDate!.compareTo(b.selectedDate!));
  }

  void _showAddTodoBottomSheet(BuildContext context) {
    final initialHeight = MediaQuery.of(context).size.height * 0.8;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SizedBox(
              height: initialHeight,
              child: AddTodoSheetScreen(),
            );
          },
        );
      },
    );
  }
}
