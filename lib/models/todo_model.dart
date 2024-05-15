import 'package:get/get.dart';

class Todo {
  late String title;
  late String description;
  late String category;
  late DateTime date;
  late RxBool isCompleted;

  Todo({
    required this.title,
    required this.description,
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
