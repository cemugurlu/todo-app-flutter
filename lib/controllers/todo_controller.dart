import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plantist/models/todo_model.dart';

class TodoController extends GetxController {
  var todos = <Todo>[].obs;
  var todoName = ''.obs;
  var notes = ''.obs;
  var user = FirebaseAuth.instance.currentUser;
  final ImagePicker _picker = ImagePicker();

  var categories = [
    'Work',
    'Personal',
    'Health & Fitness',
    'Shopping',
    'Family',
    'Home',
    'Hobbies',
  ].obs;
  var selectedCategory = 'Work'.obs;

  var priorities = [
    'Low',
    'Standard',
    'High',
  ].obs;
  var selectedPriority = 'Standard'.obs;

  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final RxBool isCalendarVisible = true.obs;
  var attachedImage = Rx<File?>(null);
  var attachedImageUrl = ''.obs;

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
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      final newTodo = Todo(
        id: UniqueKey().toString(),
        title: todoNameValue,
        category: selectedCategoryValue,
        selectedDate: selectedDate.value ?? DateTime.now(),
        description: notesValue,
        userID: userID,
        imageUrl: '',
      );

      if (attachedImage.value != null) {
        final imageUrl = await uploadImageToStorage(attachedImage.value!, userID);
        if (imageUrl != null) {
          newTodo.imageUrl = imageUrl;
        } else {
          Get.back();
          Get.snackbar('Error', 'Failed to upload image', snackPosition: SnackPosition.BOTTOM);
          return;
        }
      }

      _addTodoToFirestore(newTodo);

      todos.add(newTodo);

      todoName.value = '';
      notes.value = '';
      selectedDate.value = null;
      selectedCategory.value = 'Work';
      attachedImage.value = null;

      Get.back();

      Get.back();
    } else {
      Get.snackbar('Error', 'User not authenticated', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      attachedImage.value = File(pickedFile.path);
    }
  }

  Future<String?> uploadImageToStorage(File file, String userID) async {
    try {
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('images/$userID/${DateTime.now().millisecondsSinceEpoch}');
      final UploadTask uploadTask = storageReference.putFile(file);
      final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Failed to upload image: $e');
      return null;
    }
  }

  void toggleCompleted(int index) {
    todos[index].toggleCompleted();
    _updateTodoInFirestore(todos[index]);
  }

  void deleteTodoById(String id) {
    final index = todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _deleteTodoFromFirestore(id);
      todos.removeAt(index);
    }
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
          selectedDate: (data['selectedDate'] as Timestamp).toDate(),
          isCompleted: data['isCompleted'] ?? false,
          userID: data['userID'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          priority: data['priority'] ?? 'Low',
          hasAttachment: data['hasAttachment'] ?? false,
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
        'selectedDate': todo.selectedDate,
        'isCompleted': todo.isCompleted.value,
        'userID': todo.userID,
        'imageUrl': todo.imageUrl,
        'priority': todo.priority,
        'hasAttachment': todo.hasAttachment,
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
        'title': todo.title,
        'description': todo.description,
        'category': todo.category,
        'selectedDate': todo.selectedDate,
        'isCompleted': todo.isCompleted.value,
        'userID': todo.userID,
        'imageUrl': todo.imageUrl,
        'priority': todo.priority,
        'hasAttachment': todo.hasAttachment,
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

  Future<void> addAttachmentToTodo(File file, String todoId) async {
    try {
      final String downloadUrl = await uploadAttachmentToStorage(file);

      final Todo todo = todos.firstWhere((todo) => todo.id == todoId);
      todo.imageUrl = downloadUrl;
      todo.setAttachment(true);
      await updateTodoInFirestore(todo);
    } catch (e) {
      print('Failed to add attachment: $e');
    }
  }

  Future<String> uploadAttachmentToStorage(File file) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference = FirebaseStorage.instance.ref().child('attachments').child(fileName);
      TaskSnapshot uploadTask = await storageReference.putFile(file);
      String downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload attachment: $e');
    }
  }

  Future<void> updateTodoInFirestore(Todo todo) async {
    try {
      await _todoCollection.doc(todo.id).update({
        'imageUrl': todo.imageUrl,
        'hasAttachment': todo.hasAttachment,
      });
      print('Todo updated successfully');
    } catch (e) {
      print('Failed to update todo: $e');
    }
  }

  Future<void> deleteAttachmentFromTodo(String todoId) async {
    try {
      final Todo todo = todos.firstWhere((todo) => todo.id == todoId);
      todo.imageUrl = '';
      todo.setAttachment(false);
      await updateTodoInFirestore(todo);
    } catch (e) {
      print('Failed to delete attachment: $e');
    }
  }

  RxList<Todo> get todoList => todos;

  List<Todo> get todayTodos {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    return todos.where((todo) => isToday(todo.selectedDate, today)).toList();
  }

  List<Todo> get tomorrowTodos {
    final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
    return todos.where((todo) => isTomorrow(todo.selectedDate, tomorrow)).toList();
  }

  List<Todo> get thisWeekTodos {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime tomorrow = today.add(const Duration(days: 1));
    final DateTime eightDaysFromToday = today.add(const Duration(days: 8));

    return todos.where((todo) {
      final DateTime selectedDate = todo.selectedDate ?? today;
      return selectedDate.isAfter(today) &&
          selectedDate.isBefore(eightDaysFromToday) &&
          !isTomorrow(selectedDate, tomorrow);
    }).toList();
  }

  List<Todo> get moreThanOneWeekTodos {
    final List<Todo> allTodos = todos.toList();
    final DateTime now = DateTime.now();
    final DateTime oneWeekLater = DateTime(now.year, now.month, now.day + 7);
    return allTodos.where((todo) => isMoreThanOneWeek(todo.selectedDate, oneWeekLater)).toList();
  }

  List<Todo> get notDatedTodos {
    return todos.where((todo) => todo.selectedDate == null).toList();
  }

  bool isToday(DateTime? date, DateTime today) {
    if (date == null) return false;
    final DateTime adjustedDate = DateTime(date.year, date.month, date.day);
    return adjustedDate == today;
  }

  bool isTomorrow(DateTime? date, DateTime tomorrow) {
    if (date == null) return false;
    final DateTime adjustedDate = DateTime(date.year, date.month, date.day);
    final DateTime adjustedTomorrow = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    return adjustedDate == adjustedTomorrow;
  }

  bool isThisWeek(DateTime? date, DateTime startOfWeek, DateTime endOfWeek, DateTime today) {
    if (date == null) return false;
    return date.isAfter(startOfWeek) && date.isBefore(endOfWeek) && !isToday(date, today);
  }

  bool isMoreThanOneWeek(DateTime? date, DateTime oneWeekLater) {
    if (date == null) return false;
    final DateTime adjustedDate = DateTime(date.year, date.month, date.day);
    return adjustedDate.isAfter(oneWeekLater);
  }
}
