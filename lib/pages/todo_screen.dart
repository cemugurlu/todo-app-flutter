import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plantist/controllers/todo_controller.dart';
import 'package:plantist/pages/add_todo_sheet_screen.dart';
import 'package:intl/intl.dart';

class TodoScreen extends StatelessWidget {
  final TodoController todoController = Get.put(TodoController());

  final List<Color> randomColors = List.generate(
    100,
    (index) => Color.fromRGBO(
      Random().nextInt(256),
      Random().nextInt(256),
      Random().nextInt(256),
      1,
    ),
  );

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
      ),
      body: Obx(
        () {
          final todos = todoController.todos;
          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              final formattedDate = todo.selectedDate != null
                  ? '${todo.selectedDate!.day}.${todo.selectedDate!.month}.${todo.selectedDate!.year}'
                  : '';
              return Dismissible(
                key: Key(todo.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  todoController.deleteTodo(index);
                },
                child: Column(
                  children: [
                    ListTile(
                      leading: Obx(() => Checkbox(
                            value: todo.isCompleted.value,
                            onChanged: (value) {
                              todoController.toggleCompleted(index);
                            },
                            // Increase the size of the Checkbox
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            activeColor: const Color.fromRGBO(13, 22, 40, 1),
                            checkColor: Colors.white,
                            side: BorderSide(
                              color: randomColors[index % randomColors.length],
                            ),
                          )),
                      title: Text(todo.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(todo.category),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(formattedDate),
                                ],
                              ),
                              if (todo.selectedDate != null)
                                Text(
                                  DateFormat('dd.MM.yyyy').format(todo.selectedDate!),
                                  style: const TextStyle(fontSize: 16),
                                ),
                            ],
                          ),
                          if (index != todos.length - 1) Divider(),
                        ],
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 15.0),
        child: SizedBox(
          width: double.infinity,
          height: 80,
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
