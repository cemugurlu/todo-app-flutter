// app_routes.dart

import 'package:get/get.dart';
import 'package:plantist/screens/login_screen.dart';
import 'package:plantist/screens/welcome_screen.dart';

final routes = [
  GetPage(name: '/', page: () => const WelcomeScreen()),
  GetPage(name: '/login', page: () => LoginScreen()),
];
