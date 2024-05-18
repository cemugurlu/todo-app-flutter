import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting
import 'package:plantist/models/todo_model.dart';

class TodoDetailScreen extends StatelessWidget {
  final Todo todo;

  TodoDetailScreen({required this.todo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: ${todo.title}',
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            Text(
              'Description: ${todo.description}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 10.0),
            Text(
              'Category: ${todo.category}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 10.0),
            Text(
              'Selected Date: ${_formatDate(todo.selectedDate)}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 10.0),
            if (todo.imageUrl.isNotEmpty)
              Image.network(
                todo.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
          ],
        ),
      ),
    );
  }

  // Helper function to format the date
  String _formatDate(DateTime? date) {
    if (date != null) {
      return DateFormat('dd.MM.yyyy').format(date);
    } else {
      return 'Not set';
    }
  }
}
