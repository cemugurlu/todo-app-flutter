import 'package:get/get.dart';

class LoginController extends GetxController {
  final email = ''.obs;
  final password = ''.obs;
  final isObscure = true.obs;

  RxBool isButtonEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    debounce(email, (_) => updateButtonState(), time: const Duration(milliseconds: 10));
    debounce(password, (_) => updateButtonState(), time: const Duration(milliseconds: 10));
  }

  void updateButtonState() {
    isButtonEnabled.value = email.value.length >= 3 && password.value.length >= 6;
  }

  void togglePasswordVisibility() {
    isObscure.value = !isObscure.value;
  }
}
