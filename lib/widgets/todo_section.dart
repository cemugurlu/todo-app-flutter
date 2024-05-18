import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:plantist/controllers/todo_controller.dart';
import 'package:plantist/models/todo_model.dart';
import 'package:plantist/pages/todo_detail_screen.dart';

class TodoSection extends StatelessWidget {
  final String title;
  final List<Todo> todos;
  final TodoController todoController;

  final List<Color> randomColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.yellow,
  ];

  Color getRandomColor() {
    final random = Random();
    return randomColors[random.nextInt(randomColors.length)];
  }

  TodoSection({
    Key? key,
    required this.title,
    required this.todos,
    required this.todoController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return todos.isEmpty
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              ...todos.map((todo) {
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
                    todoController.deleteTodoById(todo.id);
                  },
                  child: ListTile(
                    leading: GestureDetector(
                      onTap: () {
                        todo.toggleCompleted();
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: getRandomColor()),
                        ),
                        child: Obx(
                          () => Center(
                            child: Icon(
                              Icons.check,
                              size: 16,
                              color: todo.isCompleted.value ? Colors.black : Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ),
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
                                if (todo.hasAttachment)
                                  const Icon(
                                    Icons.attach_file,
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
                      ],
                    ),
                    onTap: () {
                      Get.to(
                        TodoDetailScreen(todo: todo),
                      );
                    },
                  ),
                );
              }).toList(),
            ],
          );
  }
}
