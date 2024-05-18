import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plantist/models/todo_model.dart';
import 'package:plantist/pages/todo_detail_screen.dart';

class TodoSearchDelegate extends SearchDelegate<List<Todo>> {
  final List<Todo> todos;

  TodoSearchDelegate(this.todos);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, []);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredTodos = todos.where((todo) => todo.title.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: filteredTodos.length,
      itemBuilder: (context, index) {
        final todo = filteredTodos[index];
        return ListTile(
          title: Text(todo.title),
          subtitle: Text(todo.category),
          onTap: () {
            Get.to(TodoDetailScreen(todo: todo));
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredTodos = todos.where((todo) => todo.title.toLowerCase().contains(query.toLowerCase())).toList();
    final limitedSuggestions = filteredTodos.take(3).toList();
    return _buildSearchResults(limitedSuggestions);
  }

  Widget _buildSearchResults(List<Todo> todos) {
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return ListTile(
          title: Text(todo.title),
          subtitle: Text(todo.category),
          onTap: () {
            Get.to(TodoDetailScreen(todo: todo)); // Navigate to TodoDetailView
          },
        );
      },
    );
  }
}
