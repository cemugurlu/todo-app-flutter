import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plantist/controllers/login_controller.dart';

enum AuthMode { login, signup }

class AuthScreen extends StatelessWidget {
  final LoginController loginController = Get.put(LoginController());
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final AuthMode authMode;

  AuthScreen({Key? key, required this.authMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              authMode == AuthMode.login ? 'Sign in with Email' : 'Sign up with Email',
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Enter your email and password',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: 'E-mail',
                suffixIcon: Obx(
                  () {
                    if (loginController.isEmailExists.value) {
                      return Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromRGBO(13, 22, 40, 1),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ),
              onChanged: (value) {
                loginController.email.value = value;
                loginController.checkEmailExistence(value); // Check email existence when text changes
              },
            ),
            const SizedBox(height: 10),
            Obx(
              () => TextField(
                decoration: InputDecoration(
                  hintText: 'Password',
                  suffixIcon: GestureDetector(
                    onTap: () {
                      loginController.togglePasswordVisibility();
                    },
                    child: Icon(
                      loginController.isObscure.value ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
                obscureText: loginController.isObscure.value,
                onChanged: (value) => loginController.password.value = value,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(),
                ),
                GestureDetector(
                  onTap: () {
                    print('Forgot password?');
                  },
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Obx(
              () => SizedBox(
                height: 70,
                child: ElevatedButton(
                  onPressed: loginController.isButtonEnabled.value ? _authenticate : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: loginController.isButtonEnabled.value
                        ? const Color.fromRGBO(13, 22, 40, 1)
                        : const Color.fromRGBO(182, 185, 191, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    authMode == AuthMode.login ? 'Sign in' : 'Create Account',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _authenticate() async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()));

      if (authMode == AuthMode.login) {
        // Sign in
        await _auth.signInWithEmailAndPassword(
          email: loginController.email.value,
          password: loginController.password.value,
        );
      } else {
        // Sign up
        await _auth.createUserWithEmailAndPassword(
          email: loginController.email.value,
          password: loginController.password.value,
        );
      }

      Get.back();

      Get.toNamed('/todo');
    } catch (e) {
      Get.back();

      Get.snackbar(
        'Error',
        'Failed to ${authMode == AuthMode.login ? 'sign in' : 'sign up'}: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
