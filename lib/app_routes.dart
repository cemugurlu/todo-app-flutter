import 'package:get/get.dart';
import 'package:plantist/auth_mode.dart';
import 'package:plantist/pages/details_sheet_screen.dart';
import 'package:plantist/pages/auth_screen.dart';
import 'package:plantist/pages/todo_screen.dart';
import 'package:plantist/pages/welcome_screen.dart';

final routes = [
  GetPage(name: '/', page: () => const WelcomeScreen()),
  GetPage(
    name: '/login',
    page: () => AuthScreen(
      authMode: AuthMode.login,
    ),
  ),
  GetPage(
    name: '/signup',
    page: () => AuthScreen(
      authMode: AuthMode.signup,
    ),
  ),
  GetPage(name: '/todo', page: () => TodoScreen()),
  GetPage(
    name: '/details',
    page: () => DetailsSheetScreen(
      selectedDate: Rx<DateTime?>(null),
      isCalendarVisible: RxBool(false),
    ),
  ),
];
