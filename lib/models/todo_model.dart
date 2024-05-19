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
  late String imageUrl;
  late String priority; // Change from Priority to String
  List<String> tags;

  late bool hasAttachment;
  late bool selected;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.userID,
    this.selectedDate,
    bool isCompleted = false,
    this.selected = false,
    this.imageUrl = '',
    this.priority = 'Low', // Default priority as string
    this.tags = const [],
    this.hasAttachment = false,
  }) {
    this.isCompleted = isCompleted.obs;
  }

  void toggleCompleted() {
    isCompleted.value = !isCompleted.value;
    _updateTodoInFirestore();
  }

  void setAttachment(bool value) {
    hasAttachment = value;
  }

  Future<void> _updateTodoInFirestore() async {
    try {
      await FirebaseFirestore.instance.collection('todos').doc(id).update({
        'isCompleted': isCompleted.value,
      });
      print('Todo updated successfully');
    } catch (e) {
      print('Failed to update todo: $e');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'selectedDate': selectedDate,
      'description': description,
      'userID': userID,
      'isCompleted': isCompleted.value,
      'imageUrl': imageUrl,
      'hasAttachment': hasAttachment,
    };
  }

  static Todo fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      selectedDate: map['selectedDate'] != null ? (map['selectedDate'] as Timestamp).toDate() : null,
      userID: map['userID'] ?? '',
      isCompleted: map['isCompleted'] == true.obs,
      imageUrl: map['imageUrl'] ?? '',
      hasAttachment: map['hasAttachment'] ?? false,
    );
  }
}
