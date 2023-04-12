import 'dart:convert'; //para cargar el json
import 'dart:io';
import 'package:http/http.dart'
    as http; //para descargar la depencencia que queramos importar usaremos Pubspec Assist
import 'package:flutter/material.dart';
import 'package:productes_app/models/models.dart';

class ProductsService extends ChangeNotifier {
  final String _baseUrl =
      'flutter-app-productes-1aa3f-default-rtdb.europe-west1.firebasedatabase.app';
  final List<Products> products = [];
  //Creamos un producto temporal
  late Products selectedProduct;
  //Creamos una variable de tipo File, importamos .io
  File? newPicture;

  bool isLoading = true;
  bool isSaving = false;

  //Constructor
  ProductsService() {
    this.loadProducts();
  }
  //Método para cargar los productos
  Future loadProducts() async {
    //para saber cuando está cargando
    isLoading = true;
    notifyListeners();

    final url = Uri.https(_baseUrl, 'products.json');
    //Utilizamos el alias para tratar la respuesta
    final resp = await http.get(url);
    //mapeamos la respuesta, el String es el id y el producto clave: valor
    final Map<String, dynamic> productsMap = json.decode(resp.body);
    print(productsMap); //eliminar

    //Pasamos los dynamic a nuestra lista id + contenido(producto)
    productsMap.forEach((key, value) {
      final tempProduct = Products.fromMap(value);
      tempProduct.id = key;
      products.add(tempProduct);
    });

    print(products[0].name); //eliminar
    //para notificar que hemos terminado de cargar
    isLoading = false;
    notifyListeners();
  }

  Future saveOrCreateProduct(Products products) async {
    isSaving = true;
    notifyListeners();

    if (products.id == null) {
      //TODO Crearem el producte
      await createProduct(products);
    } else {
      //Actualitzant
      await updateProduct(products);
    }

    isSaving = false;
    notifyListeners();
  }

  Future<String> updateProduct(Products products) async {
    final url = Uri.https(_baseUrl, 'products/${products.id}.json');
    final resp = await http.put(url, body: products.toJson());
    final decodedData = resp.body;
    print(decodedData);

    //TODO: Actualitzar la llista local de productes
    final index =
        this.products.indexWhere((element) => element.id == products.id);
    this.products[index] = products;
    return products.id!;
  }

  Future<String> createProduct(Products products) async {
    final url = Uri.https(_baseUrl, 'products.json');
    final resp = await http.post(url, body: products.toJson());
    final decodedData = json.decode(resp.body);
    products.id = decodedData['name'];
    this.products.add(products);
    print(decodedData['name']);

    //TODO: Actualitzar la llista local de productes
    this.products.add(products);

    return products.id!;
  }

  //Método para subir la imagen
  void updateSelectedImage(String path) {
    this.newPicture = File.fromUri(Uri(path: path));
    //Actualizamos la imagen
    this.selectedProduct.picture = path;
    notifyListeners();
  }

  Future<String?> uploadImage() async {
    if (this.newPicture == null) return null;

    this.isSaving = true;
    notifyListeners();

    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/skitinium/image/upload?upload_preset=products');

    final imageUploadRequest = http.MultipartRequest('POST', url);

    final file = await http.MultipartFile.fromPath('file', newPicture!.path);

    imageUploadRequest.files.add(file);

    final streamResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamResponse);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      print('Hi ha un error!');
      print(resp.body);
      return null;
    }

    this.newPicture = null;

    final decodeData = json.decode(resp.body);
    return decodeData['secure_url'];

    //print(resp.body);
  }
}
