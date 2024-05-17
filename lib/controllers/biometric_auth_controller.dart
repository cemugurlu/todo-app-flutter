import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthController extends GetxController {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final _box = GetStorage();

  Future<bool> _checkBiometrics() async {
    return await _localAuth.canCheckBiometrics;
  }

  Future<bool> _showBiometricPrompt() async {
    try {
      final isAvailable = await _checkBiometrics();
      if (!isAvailable) {
        throw Exception('Biometric authentication is not available');
      }

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to proceed',
      );

      if (isAuthenticated) {
        Get.snackbar('Success', 'Biometric authentication successful');
        return true;
      } else {
        Get.snackbar('Error', 'Biometric authentication failed');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      Get.snackbar('Error', 'Biometric authentication failed');
      return false;
    }
  }

  Future<bool> authenticate() async {
    final isAuthenticated = await _showBiometricPrompt();
    return isAuthenticated;
  }

  void saveUserCredentials(String email, String password) {
    print('Saving credentials: email=$email, password=$password');
    _box.write('userEmail', email);
    _box.write('userPassword', password);
  }

  Map<String, String>? getUserCredentials() {
    final email = _box.read('userEmail');
    final password = _box.read('userPassword');
    print('Retrieved email: $email');
    print('Retrieved password: $password');
    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }
}
