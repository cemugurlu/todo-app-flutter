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
  late String imageUrl; // Add imageUrl field

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
    this.imageUrl = '', // Initialize imageUrl field
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

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'selectedDate': selectedDate,
      'description': description,
      'userID': userID,
      'isCompleted': isCompleted.value,
      'imageUrl': imageUrl, // Include imageUrl in the map
    };
  }

  static Todo fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      selectedDate: map['selectedDate']?.toDate(),
      description: map['description'],
      userID: map['userID'],
      isCompleted: map['isCompleted'] == true.obs,
      imageUrl: map['imageUrl'] ?? '', // Assign imageUrl from map, default to empty string if not present
    );
  }
}
