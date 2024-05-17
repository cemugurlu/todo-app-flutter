import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:plantist/auth_mode.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();

  final email = ''.obs;
  final password = ''.obs;
  final confirmPassword = ''.obs;
  final isObscure = true.obs;
  RxBool isButtonEnabled = false.obs;
  final isEmailExists = false.obs;

  String? biometricEmail;
  String? biometricPassword;

  @override
  void onInit() {
    super.onInit();
    debounce(email, (_) => updateButtonState(), time: const Duration(milliseconds: 10));
    debounce(password, (_) => updateButtonState(), time: const Duration(milliseconds: 10));
    debounce(confirmPassword, (_) => updateButtonState(), time: const Duration(milliseconds: 10));
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
      final emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailPattern.hasMatch(email)) {
        throw const FormatException('Invalid email format');
      }

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
      isEmailExists.value = false;
    }
  }

  Future<void> authenticate(AuthMode authMode) async {
    try {
      if (authMode == AuthMode.login) {
        if (biometricEmail != null && biometricPassword != null) {
          email.value = biometricEmail!;
          password.value = biometricPassword!;
        }

        await _auth.signInWithEmailAndPassword(email: email.value, password: password.value);
      } else {
        await _auth.createUserWithEmailAndPassword(email: email.value, password: password.value);

        biometricEmail = email.value;
        biometricPassword = password.value;
      }
    } catch (e) {
      print('Authentication failed: $e');
    }
  }

  Future<bool> authenticateBiometric() async {
    try {
      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        throw Exception('Biometric authentication not available.');
      }

      bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to proceed',
      );

      return didAuthenticate;
    } catch (e) {
      print('Biometric authentication failed: $e');
      return false;
    }
  }

  Future<void> saveUserId(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).set({'userId': userId});
    } catch (e) {
      print('Error saving user ID: $e');
    }
  }
}
