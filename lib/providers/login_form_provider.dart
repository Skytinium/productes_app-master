import 'package:flutter/material.dart';

class LoginFormProvider extends ChangeNotifier {
  //todo formulario tiene que tener una Key enlazada para saber de que formulario se trata
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool isValidForm() {
    // Imprime si el formulario es true o false
    print('Valor del formulari: ${formKey.currentState?.validate()}');
    // Imprime el email y contraseña introducidos
    print('$email - $password');
    return formKey.currentState?.validate() ?? false;
  }
}
