import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plantist/controllers/todo_controller.dart';
import 'package:plantist/pages/details_sheet_screen.dart';

class AddTodoSheetScreen extends StatelessWidget {
  final TodoController todoController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New Reminder',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        toolbarHeight: 60,
        leadingWidth: 90,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: TextButton(
              onPressed: () {
                todoController.addTodo();
              },
              child: const Text(
                'Add',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              onChanged: (value) => todoController.todoName.value = value,
              decoration: const InputDecoration(
                labelText: 'Enter your todo',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: (value) => todoController.notes.value = value,
              decoration: const InputDecoration(
                labelText: 'Notes',
              ),
            ),
            const SizedBox(height: 10),
            Obx(() {
              return DropdownButton<String>(
                value: todoController.selectedCategory.value,
                onChanged: (newValue) {
                  todoController.selectedCategory.value = newValue!;
                },
                items: todoController.categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
              );
            }),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                _showDetailsBottomSheet();
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                side: const BorderSide(color: Colors.black),
              ),
              child: const ListTile(
                title: Text(
                  'Details',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  'Today',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailsBottomSheet() {
    Get.bottomSheet(
      SizedBox(
        width: double.infinity,
        height: Get.height * 0.9,
        child: DetailsSheetScreen(
          selectedDate: todoController.selectedDate,
          isCalendarVisible: todoController.isCalendarVisible,
        ),
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(300)),
      ),
    );
  }
}
