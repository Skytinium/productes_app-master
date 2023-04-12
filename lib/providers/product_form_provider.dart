import 'package:flutter/material.dart';
import 'package:productes_app/models/models.dart';

//Creamos un nuevo Provider para poder editar los productos desde el formulario
class ProductFormProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Products tempProduct;

  //Constructor
  ProductFormProvider(this.tempProduct);
  //método boleano si no es válido retorna false.
  bool isValidForm() {
    print(tempProduct.name);
    print(tempProduct.price);
    print(tempProduct.available);
    return formKey.currentState?.validate() ?? false;
  }

  //método para actualizar la disponibilidad
  updateAvaliability(bool value) {
    print(value);
    this.tempProduct.available = value;
    notifyListeners();
  }
}
