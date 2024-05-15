// app_routes.dart

import 'package:get/get.dart';
import 'package:plantist/pages/details_sheet_screen.dart';
import 'package:plantist/pages/login_screen.dart';
import 'package:plantist/pages/todo_screen.dart';
import 'package:plantist/pages/welcome_screen.dart';

final routes = [
  GetPage(name: '/', page: () => const WelcomeScreen()),
  GetPage(name: '/login', page: () => LoginScreen()),
  GetPage(name: '/todo', page: () => TodoScreen()),
  GetPage(name: '/details', page: () => DetailsSheetScreen())
];
