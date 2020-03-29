import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wimp/model/productModel.dart';

class ProductApi {
  static Future<List<ProductModel>> getClosestProducts() async {
    final response = await http.get('http://15.236.118.131:5000/products');
    //final response =  await http.get('https://my-json-server.typicode.com/pauln19/demo/products');

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
      return (json.decode(response.body) as List)
          .map((data) => new ProductModel.fromJson(data))
          .toList();
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to fetch stores');
    }
  }
}
