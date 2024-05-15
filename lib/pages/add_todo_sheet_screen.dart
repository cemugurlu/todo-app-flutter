import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plantist/controllers/todo_controller.dart';
import 'package:plantist/pages/details_sheet_screen.dart';

class AddTodoSheetScreen extends StatelessWidget {
  final TodoController todoController = Get.put(TodoController());

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
              controller: todoController.todoNameController,
              decoration: const InputDecoration(
                labelText: 'Enter your todo',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: todoController.notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                _showDetailsBottomSheet(context);
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                side: const BorderSide(color: Colors.black),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 3, top: 5, bottom: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Details',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Today',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.black),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailsBottomSheet(BuildContext context) {
    final expandedHeight = MediaQuery.of(context).size.height * 0.85;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: expandedHeight,
          child: DetailsSheetScreen(),
        );
      },
    );
  }
}
