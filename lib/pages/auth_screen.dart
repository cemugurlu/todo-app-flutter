import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plantist/auth_mode.dart';
import 'package:plantist/controllers/login_controller.dart';
import 'package:plantist/controllers/biometric_auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatelessWidget {
  final LoginController loginController = Get.put(LoginController());
  final BiometricAuthController biometricAuthController = Get.put(BiometricAuthController());
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
              ),
              onChanged: (value) {
                loginController.email.value = value;
              },
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Password',
              ),
              obscureText: true,
              onChanged: (value) {
                loginController.password.value = value;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 70,
              child: ElevatedButton(
                onPressed: () {
                  if (authMode == AuthMode.login) {
                    _signIn();
                  } else {
                    _signup();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(13, 22, 40, 1),
                ),
                child: Text(
                  authMode == AuthMode.login ? 'Sign in' : 'Create Account',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (authMode == AuthMode.signup)
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 244, 147, 1)),
                onPressed: () async {
                  final success = await biometricAuthController.authenticate();
                  if (success) {
                    _signup();
                  }
                },
                child: const Text(
                  'Use Biometrics for Sign Up',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            if (authMode == AuthMode.login)
              ElevatedButton(
                onPressed: _signInWithBiometrics,
                child: const Text('Sign In with Biometrics'),
              ),
          ],
        ),
      ),
    );
  }

  void _signup() async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()));
      await _auth.createUserWithEmailAndPassword(
        email: loginController.email.value,
        password: loginController.password.value,
      );

      final email = loginController.email.value;
      final password = loginController.password.value;
      biometricAuthController.saveUserCredentials(email, password);

      Get.back();

      _showBiometricSignInConfirmationDialog();
    } catch (e) {
      Get.back();

      Get.snackbar(
        'Error',
        'Failed to sign up: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _signIn() async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()));

      await _auth.signInWithEmailAndPassword(
        email: loginController.email.value,
        password: loginController.password.value,
      );

      Get.toNamed('/todo');
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Failed to sign in: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _signInWithBiometrics() async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()));

      final success = await biometricAuthController.authenticate();
      if (success) {
        final credentials = biometricAuthController.getUserCredentials();
        if (credentials == null) {
          throw Exception('Biometric credentials not found');
        }

        final email = credentials['email'];
        final password = credentials['password'];
        if (email == null || password == null) {
          throw Exception('Email or password is null');
        }

        await _auth.signInWithEmailAndPassword(email: email, password: password);

        Get.toNamed('/todo');
      } else {
        Get.back();
        Get.snackbar(
          'Error',
          'Biometric authentication failed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Failed to sign in: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showBiometricSignInConfirmationDialog() {
    Get.defaultDialog(
      title: 'Biometric Sign-In',
      middleText: 'Do you want to use biometrics for sign-in?',
      confirm: ElevatedButton(
        onPressed: () {
          Get.back(result: true);
        },
        child: const Text('Yes'),
      ),
      cancel: ElevatedButton(
        onPressed: () {
          Get.back(result: false);
        },
        child: const Text('No'),
      ),
    ).then((value) {
      if (value == true) {
        _authenticate();
      } else {
        Get.offAllNamed('/todo');
      }
    });
  }

  void _authenticate() async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()));
      final success = await biometricAuthController.authenticate();
      if (success) {
        await _auth.signInWithEmailAndPassword(
          email: loginController.email.value,
          password: loginController.password.value,
        );

        Get.offAllNamed('/todo');
      } else {
        Get.back();
        Get.snackbar(
          'Error',
          'Biometric authentication failed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back();
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
