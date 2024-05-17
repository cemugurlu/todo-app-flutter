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
  List<String> attachments;
  late bool selected; // New selected property

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.userID,
    this.selectedDate,
    this.attachments = const [],
    bool isCompleted = false,
    this.selected = false, // Initialize selected with false
  }) {
    this.isCompleted = isCompleted.obs;
  }

  void toggleCompleted() {
    isCompleted.value = !isCompleted.value;
    _updateTodoInFirestore();
  }

  void _updateTodoInFirestore() async {
    try {
      await FirebaseFirestore.instance.collection('todos').doc(id).update({
        'isCompleted': isCompleted.value,
      });
      print('Todo updated successfully');
    } catch (e) {
      print('Failed to update todo: $e');
    }
  }

  void addAttachment(String url) {
    attachments.add(url);
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
