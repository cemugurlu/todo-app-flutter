import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class Todo {
  late String id;
  late String title;
  late String description;
  late String category;
  late DateTime date;
  late RxBool isCompleted;
  late String userID; // Add userID field to the Todo model

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    required this.userID, // Initialize userID in the constructor
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
      date: (map['date'] as Timestamp).toDate(),
      userID: map['userID'], // Assign userID from Firestore data
      isCompleted: map['isCompleted'],
    );
  }
}
