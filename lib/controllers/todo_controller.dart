import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plantist/models/todo_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TodoController extends GetxController {
  var todos = <Todo>[].obs;
  var todoName = ''.obs;
  var notes = ''.obs;
  var user = FirebaseAuth.instance.currentUser;

  var categories = [
    'Work',
    'Personal',
    'Health & Fitness',
    'Shopping',
    'Family',
    'Home',
    'Hobbies',
  ].obs;
  var selectedCategory = 'Work'.obs; // Default category

  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final RxBool isCalendarVisible = true.obs;

  final CollectionReference _todoCollection = FirebaseFirestore.instance.collection('todos');

  String? getCurrentUser() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      String userID = user.uid;
      print('Current user ID: $userID');
      return userID;
    } else {
      print('User is not authenticated.');
      return null;
    }
  }

  @override
  void onInit() {
    fetchUserTodos();
    super.onInit();
  }

  void addTodo() async {
    final todoNameValue = todoName.value.trim();
    final notesValue = notes.value.trim();
    final String? userID = getCurrentUser();
    final selectedCategoryValue = selectedCategory.value;

    if (todoNameValue.isEmpty) {
      Get.snackbar('Error', 'Todo name cannot be empty', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (userID != null) {
      final newTodo = Todo(
        id: UniqueKey().toString(),
        title: todoNameValue,
        category: selectedCategoryValue,
        selectedDate: selectedDate.value ?? DateTime.now(),
        description: notesValue,
        userID: userID,
      );

      _addTodoToFirestore(newTodo);

      todos.add(newTodo);

      todoName.value = '';
      notes.value = '';
      selectedDate.value = null;
      selectedCategory.value = 'Work';

      Get.back();
    }
  }

  void toggleCompleted(int index) {
    todos[index].toggleCompleted();
    _updateTodoInFirestore(todos[index]);
  }

  void deleteTodo(int index) {
    _deleteTodoFromFirestore(todos[index].id);
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
          selectedDate: (data['date'] as Timestamp).toDate(),
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
        'date': todo.selectedDate,
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

  void _deleteTodoFromFirestore(String id) async {
    try {
      await _todoCollection.doc(id).delete();
      print('Todo deleted successfully');
    } catch (e) {
      print('Failed to delete todo: $e');
    }
  }

  RxList<Todo> get todoList => todos;

  List<Todo> get todayTodos {
    return todos.where((todo) => isToday(todo.selectedDate)).toList();
  }

  List<Todo> get tomorrowTodos {
    return todos.where((todo) => isTomorrow(todo.selectedDate)).toList();
  }

  List<Todo> get thisWeekTodos {
    return todos.where((todo) => isThisWeek(todo.selectedDate)).toList();
  }

  bool isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool isTomorrow(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    final tomorrow = now.add(Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }

  bool isThisWeek(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    final endOfWeek = now.add(Duration(days: DateTime.daysPerWeek - now.weekday));
    return date.isAfter(now) && date.isBefore(endOfWeek) && !isTomorrow(date);
  }

  Future<void> attachFile() async {
    final XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (file != null) {
      try {
        final String fileName = file.path.split('/').last;
        final Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('uploads/$fileName');
        final UploadTask uploadTask = firebaseStorageRef.putFile(File(file.path));
        await uploadTask.whenComplete(() => null);
        final String downloadUrl = await firebaseStorageRef.getDownloadURL();

        // Add the URL to the todo's attachments list
        final List<String> attachments = [downloadUrl];
        todos.forEach((todo) {
          if (todo.selected) {
            todo.attachments.addAll(attachments);
            _updateTodoInFirestore(todo);
          }
        });
      } catch (e) {
        print('Failed to upload file: $e');
        Get.snackbar('Error', 'Failed to upload file: $e');
      }
    }
  }
}
