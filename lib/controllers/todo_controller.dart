import 'package:get/get.dart';
import 'package:plantist/models/todo_model.dart';

class TodoController extends GetxController {
  var todos = <Todo>[].obs;

  void addTodo(Todo todo) {
    todos.add(todo);
  }

  @override
  void onInit() {
    super.onInit();
    addTodo(Todo(name: 'Make lasagna', category: 'Food', date: DateTime.now()));
    addTodo(Todo(name: 'Finish the project', category: 'Work', date: DateTime.now()));
    addTodo(Todo(name: 'Hang out', category: 'Personal', date: DateTime.now()));
  }

  void toggleCompleted(int index) {
    todos[index].toggleCompleted();
  }
}
