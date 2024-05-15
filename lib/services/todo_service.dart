import 'package:cloud_firestore/cloud_firestore.dart';

class TodoService {
  final CollectionReference _todoCollection = FirebaseFirestore.instance.collection('todos');

  Future<void> addTodo({
    required String category,
    required DateTime date,
    required String description,
    required String title,
  }) async {
    try {
      await _todoCollection.add({
        'category': category,
        'date': date,
        'description': description,
        'title': title,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Todo added successfully');
    } catch (e) {
      print('Failed to add todo: $e');
    }
  }
}
