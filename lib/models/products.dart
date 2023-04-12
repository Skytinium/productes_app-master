// To parse this JSON data, do
//
//     final products = productsFromMap(jsonString);

import 'dart:convert';

class Products {
  Products({
    required this.available,
    required this.name,
    this.picture,
    required this.price,
    this.id,
  });

  bool available;
  String name;
  String? picture;
  double price;
  // nuestros productos no tenían id, por lo tanto lo creamos
  // es opcional (todos los productos tendrán id) pero no se lo asignamos al constructor
  String? id;

  factory Products.fromJson(String str) => Products.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Products.fromMap(Map<String, dynamic> json) => Products(
        available: json["available"],
        name: json["name"],
        picture: json["picture"],
        price: json["price"].toDouble(),
      );

  Map<String, dynamic> toMap() => {
        "available": available,
        "name": name,
        "picture": picture,
        "price": price,
      };

  // método que retorna una copia del producto
  Products copy() => Products(
      available: this.available,
      name: this.name,
      picture: this.picture,
      price: this.price,
      id: this.id);
}
