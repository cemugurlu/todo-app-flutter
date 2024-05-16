import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class Todo {
  late String id;
  late String title;
  late String description;
  late String category;
  late RxBool isCompleted;
  late String userID;
  late DateTime? selectedDate;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.userID,
    this.selectedDate,
    bool isCompleted = false,
  }) {
    this.isCompleted = isCompleted.obs;
  }

  void toggleCompleted() {
    isCompleted.value = !isCompleted.value;
  }

  factory Todo.fromMap(Map<String, dynamic> map, String id) {
    return Todo(
      id: id,
      title: map['title'],
      description: map['description'],
      category: map['category'],
      userID: map['userID'],
      selectedDate: map['selectedDate'] != null ? (map['selectedDate'] as Timestamp).toDate() : null,
      isCompleted: map['isCompleted'],
    );
  }
}
