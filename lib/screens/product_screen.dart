import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:productes_app/providers/product_form_provider.dart';
import 'package:productes_app/services/products_service.dart';
import 'package:productes_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

import '../ui/input_decorations.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //creamos el provider para acceder
    final productService = Provider.of<ProductsService>(context);

    //Extraemos el Scaffold para incluirlo dentro del widget y llamar a nuestro provider
    //Hacemos lo mismo que en el main, crearnos nuestro propio appState con el changeNotifierProvider
    //De esta forma tenemos acceso ProductFormProvider
    return ChangeNotifierProvider(
        create: (_) => ProductFormProvider(productService.selectedProduct),
        child: _ProductScreenBody(productService: productService));
  }
}

class _ProductScreenBody extends StatelessWidget {
  const _ProductScreenBody({
    Key? key,
    required this.productService,
  }) : super(key: key);

  final ProductsService productService;

  @override
  Widget build(BuildContext context) {
    final productFrom = Provider.of<ProductFormProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                ProductImage(url: productService.selectedProduct.picture),
                Positioned(
                  top: 60,
                  left: 20,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  right: 20,
                  child: IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Mostrar un diálogo para que el usuario pueda elegir entre tomar una foto con la cámara o elegir una imagen de la galería.
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Elegir imagen'),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  GestureDetector(
                                    child: const Text('Cámara'),
                                    onTap: () async {
                                      Navigator.of(context).pop();
                                      final XFile? photo =
                                          await picker.pickImage(
                                        source: ImageSource.camera,
                                        imageQuality: 100,
                                      );
                                      if (photo == null) {
                                        print('No temin imatge');
                                      } else {
                                        print('Tenim imatge ${photo.path}');
                                        productService
                                            .updateSelectedImage(photo.path);
                                      }
                                    },
                                  ),
                                  const Padding(padding: EdgeInsets.all(8.0)),
                                  GestureDetector(
                                    child: const Text('Galería'),
                                    onTap: () async {
                                      Navigator.of(context).pop();
                                      final XFile? image =
                                          await picker.pickImage(
                                        source: ImageSource.gallery,
                                        imageQuality: 100,
                                      );
                                      if (image == null) {
                                        print('No temin imatge');
                                      } else {
                                        print('Tenim imatge ${image.path}');
                                        productService
                                            .updateSelectedImage(image.path);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            _ProductForm(),
            const SizedBox(
              height: 100,
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
          child: productService.isSaving
              ? CircularProgressIndicator(color: Colors.white)
              : Icon(Icons.save_outlined),
          onPressed: productService.isSaving
              ? null
              : () async {
                  //TODO: Emmagatzemar producte
                  if (!productFrom.isValidForm()) return;
                  final String? imageUrl = await productService.uploadImage();
                  if (imageUrl != null)
                    productFrom.tempProduct.picture = imageUrl;
                  productService.saveOrCreateProduct(productFrom.tempProduct);
                }),
    );
  }
}

class _ProductForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Variable de nuestro Provider
    final productFrom = Provider.of<ProductFormProvider>(context);
    // Variable temporal de producto
    final tempProduct = productFrom.tempProduct;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        decoration: _buildBoxDecoration(),
        child: Form(
          //asociamos el formKey de nuestro provider
          key: productFrom.formKey,
          //para quitar el error cuando el campo está en blanco
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              const SizedBox(height: 10),
              TextFormField(
                initialValue: tempProduct.name,
                onChanged: (value) => tempProduct.name = value,
                validator: (value) {
                  if (value == null || value.length < 1)
                    return 'El nom es obligatori';
                },
                decoration: InputDecorations.authInputDecoration(
                    hintText: 'Nom del producte', labelText: 'Nom:'),
              ),
              const SizedBox(height: 30),
              TextFormField(
                initialValue: '${tempProduct.price}',
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^(\d+)?\.?\d{0,2}')),
                ],
                onChanged: (value) {
                  if (double.tryParse(value) == null) {
                    tempProduct.price = 0;
                  } else {
                    tempProduct.price = double.parse(value);
                  }
                },
                validator: (value) {
                  if (value == null || value.length < 1)
                    return 'El preu es obligatori';
                },
                keyboardType: TextInputType.number,
                decoration: InputDecorations.authInputDecoration(
                    hintText: '99€', labelText: 'Preu:'),
              ),
              const SizedBox(height: 30),
              SwitchListTile.adaptive(
                value: tempProduct.available,
                title: const Text('Disponible'),
                activeColor: Colors.indigo,
                //actualizamos la disponibilidad del producto temporal desde nuestro provider
                //3 variables para la sintaxis
                onChanged: productFrom.updateAvaliability,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(25),
          bottomLeft: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 5),
              blurRadius: 5),
        ],
      );
}
