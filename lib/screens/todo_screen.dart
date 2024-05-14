import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plantist/controllers/todo_controller.dart';
import 'package:plantist/models/todo_model.dart';
import 'dart:math';

class TodoScreen extends StatelessWidget {
  final TodoController todoController = Get.put(TodoController());

  // Generate a list of random colors
  final List<Color> randomColors = List.generate(
    100, // Number of colors you want
    (index) => Color.fromRGBO(
      Random().nextInt(256), // Random red value
      Random().nextInt(256), // Random green value
      Random().nextInt(256), // Random blue value
      1, // Alpha value (full opacity)
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
      body: Obx(() {
        final todos = todoController.todos;
        return ListView.builder(
          itemCount: todos.length,
          itemBuilder: (context, index) {
            final todo = todos[index];
            // Format the date
            final formattedDate = '${todo.date.day}/${todo.date.month}/${todo.date.year}';
            return Column(
              children: [
                ListTile(
                  leading: Obx(() {
                    return SizedBox(
                      width: 30,
                      child: Checkbox(
                        value: todo.isCompleted.value,
                        onChanged: (value) {
                          todoController.toggleCompleted(index);
                        },
                        shape: const CircleBorder(),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        activeColor: const Color.fromRGBO(13, 22, 40, 1),
                        side: BorderSide(
                          color: randomColors[index % randomColors.length],
                        ),
                      ),
                    );
                  }),
                  title: Text(todo.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Category: ${todo.category}'),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                          ),
                          const SizedBox(width: 3),
                          Text(formattedDate),
                        ],
                      ), // Use formatted date
                    ],
                  ),
                  onTap: () {
                    // Handle todo tap
                    // You can navigate to a detail screen or do something else
                  },
                ),
                if (index != todos.length - 1) Divider(), // Add divider if not the last item
              ],
            );
          },
        );
      }),
    );
  }
}
