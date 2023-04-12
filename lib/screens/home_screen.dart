import 'package:flutter/material.dart';
import 'package:productes_app/models/models.dart';
import 'package:productes_app/screens/screens.dart';
import 'package:productes_app/services/services.dart';
import 'package:productes_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //creamos nuestro provider
    final productsService = Provider.of<ProductsService>(context);
    // mostraremos la pantalla de carga hasta que termine de hacer la petición
    if (productsService.isLoading) return const LoadingScreen();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productes'),
      ),
      body: ListView.builder(
        itemCount: productsService.products.length,
        itemBuilder: (BuildContext context, int index) => GestureDetector(
            child: ProductCard(products: productsService.products[index]),
            onTap: () {
              productsService.newPicture = null;
              //Le pasamos la copia al pulsar el producto
              productsService.selectedProduct =
                  productsService.products[index].copy();
              Navigator.of(context).pushNamed('product');
            }),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          productsService.newPicture = null;
          productsService.selectedProduct = Products(
            available: true,
            name: '',
            price: 0,
          );
          Navigator.of(context).pushNamed('product');
        },
      ),
    );
  }
}
