import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final email = ''.obs;
  final password = ''.obs;
  final confirmPassword = ''.obs; // Added for signup scenario
  final isObscure = true.obs;
  RxBool isButtonEnabled = false.obs;
  final isEmailExists = false.obs; // Observable to track if email exists

  @override
  void onInit() {
    super.onInit();
    debounce(email, (_) => updateButtonState(), time: const Duration(milliseconds: 10));
    debounce(password, (_) => updateButtonState(), time: const Duration(milliseconds: 10));
    debounce(confirmPassword, (_) => updateButtonState(),
        time: const Duration(milliseconds: 10)); // Added for signup scenario
  }

  void updateButtonState() {
    if (password.value.length >= 6) {
      if (confirmPassword.isNotEmpty && confirmPassword.value != password.value) {
        isButtonEnabled.value = false;
        return;
      }
    }
    isButtonEnabled.value = email.value.length >= 3 && password.value.length >= 6;
  }

  void togglePasswordVisibility() {
    isObscure.value = !isObscure.value;
  }

  Future<void> checkEmailExistence(String email) async {
    try {
      print('Checking email existence for: $email');
      // Check if the email is properly formatted
      final emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailPattern.hasMatch(email)) {
        throw FormatException('Invalid email format');
      }

      // Check if the email already exists in Firebase Auth
      final user = await _auth.fetchSignInMethodsForEmail(email);
      if (user.isNotEmpty) {
        isEmailExists.value = true;
        print('Email already exists');
      } else {
        isEmailExists.value = false;
        print('Email does not exist');
      }
    } catch (e) {
      print('Failed to check email existence: $e');
      isEmailExists.value = false; // Reset the email existence status
    }
  }

  Future<void> authenticate(AuthMode authMode) async {
    try {
      if (authMode == AuthMode.login) {
        await _auth.signInWithEmailAndPassword(email: email.value, password: password.value);
      } else {
        await _auth.createUserWithEmailAndPassword(email: email.value, password: password.value);
      }
    } catch (e) {
      print('Authentication failed: $e');
    }
  }
}

enum AuthMode { login, signup }
