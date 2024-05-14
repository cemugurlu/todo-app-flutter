import 'package:get/get.dart';

class Todo {
  late String name;
  late String category;
  late DateTime date;
  late RxBool isCompleted;

  Todo({
    required this.name,
    required this.category,
    required this.date,
    bool isCompleted = false,
  }) {
    this.isCompleted = isCompleted.obs;
  }

  void toggleCompleted() {
    isCompleted.value = !isCompleted.value;
  }
}
