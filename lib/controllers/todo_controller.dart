import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plantist/models/todo_model.dart';

class TodoController extends GetxController {
  var todos = <Todo>[].obs;
  final TextEditingController todoNameController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  void addTodo() {
    final todoName = todoNameController.text.trim();
    final notes = notesController.text.trim();

    if (todoName.isEmpty) {
      Get.snackbar('Error', 'Todo name cannot be empty', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final newTodo = Todo(
      title: todoName,
      category: 'Uncategorized',
      date: DateTime.now(),
      description: notes,
    );

    todos.add(newTodo);
    Get.back();
  }

  void toggleCompleted(int index) {
    todos[index].toggleCompleted();
  }

  @override
  void onClose() {
    todoNameController.dispose();
    notesController.dispose();
    super.onClose();
  }

  // Getter method to observe todos using Obx
  RxList<Todo> get todoList => todos;
}
