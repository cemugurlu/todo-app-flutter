import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plantist/controllers/login_controller.dart';

class LoginScreen extends StatelessWidget {
  final LoginController loginController = Get.put(LoginController());
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Sign in with Email',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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
                    if (loginController.email.value.isNotEmpty) {
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
              onChanged: (value) => loginController.email.value = value,
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
                child: Ink(
                  decoration: BoxDecoration(
                    color: loginController.isButtonEnabled.value
                        ? const Color.fromRGBO(13, 22, 40, 1)
                        : const Color.fromRGBO(181, 185, 191, 1),
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(40.0),
                    onTap: loginController.isButtonEnabled.value ? _signIn : null,
                    splashColor: Colors.blue,
                    child: const Center(
                      child: Text(
                        "Sign in",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _signIn() async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()));

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: loginController.email.value,
        password: loginController.password.value,
      );

      // Hide loading indicator
      Get.back();

      // Navigate to the TodoScreen
      Get.toNamed('/todo');
    } catch (e) {
      // Hide loading indicator
      Get.back();

      // Show error message using SnackBar
      Get.snackbar(
        'Error',
        'Failed to sign in: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
