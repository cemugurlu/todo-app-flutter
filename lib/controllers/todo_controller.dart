import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plantist/models/todo_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TodoController extends GetxController {
  var todos = <Todo>[].obs;
  var todoName = ''.obs;
  var notes = ''.obs;
  var user = FirebaseAuth.instance.currentUser;

  final CollectionReference _todoCollection = FirebaseFirestore.instance.collection('todos');

  String? getCurrentUser() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      String userID = user.uid;
      print('Current user ID: $userID');
      return userID; // Return userID if it exists
    } else {
      print('User is not authenticated.');
      return null; // Return null if user is not authenticated
    }
  }

  @override
  void onInit() {
    fetchUserTodos();
    super.onInit();
  }

  void addTodo() {
    final todoNameValue = todoName.value.trim();
    final notesValue = notes.value.trim();

    if (todoNameValue.isEmpty) {
      Get.snackbar('Error', 'Todo name cannot be empty', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    String? userID = getCurrentUser();
    if (userID != null) {
      final newTodo = Todo(
        id: UniqueKey().toString(),
        title: todoNameValue,
        category: 'Uncategorized',
        date: DateTime.now(),
        description: notesValue,
        userID: userID,
      );

      _addTodoToFirestore(newTodo);

      fetchUserTodos();
    }

    todoName.value = '';
    notes.value = '';
    Get.back();
  }

  void toggleCompleted(int index) {
    todos[index].toggleCompleted();
    _updateTodoInFirestore(todos[index]);
  }

  void fetchUserTodos() async {
    try {
      final querySnapshot = await _todoCollection.where('userID', isEqualTo: user!.uid).get();
      todos.value = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Todo(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          category: data['category'] ?? '',
          date: (data['date'] as Timestamp).toDate(),
          isCompleted: data['isCompleted'] ?? false,
          userID: data['userID'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Failed to fetch user todos: $e');
    }
  }

  void _addTodoToFirestore(Todo todo) async {
    try {
      await _todoCollection.add({
        'title': todo.title,
        'description': todo.description,
        'category': todo.category,
        'date': todo.date,
        'isCompleted': todo.isCompleted.value,
        'userID': todo.userID,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Todo added successfully');
    } catch (e) {
      print('Failed to add todo: $e');
    }
  }

  void _updateTodoInFirestore(Todo todo) async {
    try {
      await _todoCollection.doc(todo.id).update({
        'isCompleted': todo.isCompleted.value,
      });
      print('Todo updated successfully');
    } catch (e) {
      print('Failed to update todo: $e');
    }
  }

  RxList<Todo> get todoList => todos;
}
