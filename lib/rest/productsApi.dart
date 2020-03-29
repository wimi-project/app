
import 'dart:convert';

import 'package:wimp/model/productModel.dart';
import 'package:wimp/model/supermarketModel.dart';
import 'package:http/http.dart' as http;

class ProductApi {

  static Future<List<ProductModel>> getClosestProducts() async {
    final response =  await http.get('http://ec2-52-47-192-233.eu-west-3.compute.amazonaws.com:5000/products');

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
      return (json.decode(response.body) as List)
          .map((data) => new ProductModel.fromJson(data))
          .toList();
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to fetch supermarkets');
    }
  }

}